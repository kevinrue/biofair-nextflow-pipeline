// Include modules
include { READ_10X_COUNTS_MTX } from './modules/read-10x-counts-mtx.nf'
include { READ_10X_COUNTS_H5 } from './modules/read-10x-counts-h5.nf'
include { RNA_QC } from './modules/rna-qc.nf'
include { SCE_FILTER } from './modules/sce-filter.nf'
include { NORMALIZE_RNA_COUNTS_SE } from './modules/normalize-rna-counts-se.nf'
include { CHOOSE_RNA_HVGS_SE } from './modules/choose-rna-hvgs-se.nf'
include { PLOT_COLDATA as PLOT_COLDATA_SUM } from './modules/plot-coldata.nf'
include { PLOT_COLDATA as PLOT_COLDATA_DETECTED } from './modules/plot-coldata.nf'

/*
* Pipeline parameters
*/
params {
    input_type: String? = null
    matrix_file: String? = null
    barcodes_file: String? = null
    features_file: String? = null
    hdf5_file: String? = null
    sample_name: String = 'my_sample'
    mitochondrial_prefix: String = 'MT-'
    mitochondrial_threshold: Float = 3.0
    plot_qc_sum_width: Float = 3.0
    plot_qc_sum_height: Float = 5.0
    plot_qc_detected_width: Float = 3.0
    plot_qc_detected_height: Float = 5.0
    metadata_filters: String? = null
}

workflow {

    main:
    def meta = [id: params.sample_name]
    def counts

    if( !params.input_type ) {
        error "Specify --input_type as 'mtx' or 'hdf5'."
    }
    else if( params.input_type == 'mtx' ) {
        if( !params.matrix_file || !params.barcodes_file || !params.features_file ) {
            error "For input_type 'mtx', provide --matrix_file, --barcodes_file, and --features_file."
        }
        counts = READ_10X_COUNTS_MTX(
            Channel.of(tuple(
                meta,
                file(params.matrix_file),
                file(params.barcodes_file),
                file(params.features_file)
            )),
            params.sample_name
        )
    }
    else if( params.input_type == 'hdf5' ) {
        if( !params.hdf5_file ) {
            error "For input_type 'hdf5', provide --hdf5_file."
        }
        counts = READ_10X_COUNTS_H5(
            Channel.of(tuple(meta, file(params.hdf5_file))),
            params.sample_name
        )
    }
    else {
        error "Unsupported input_type '${params.input_type}'. Choose 'mtx' or 'hdf5'."
    }

    if( !params.metadata_filters ) {
        error "Specify --metadata_filters with a JSON file containing rowdata and coldata filters."
    }

    def qc = RNA_QC(counts.outfile, params.mitochondrial_prefix, params.mitochondrial_threshold)
    def metadataFilterFile = file(params.metadata_filters)
    def filterInput = qc.outfile.map { filterMeta, infile -> tuple(filterMeta, infile, metadataFilterFile) }
    def filtered = SCE_FILTER(filterInput)
    def normalized = NORMALIZE_RNA_COUNTS_SE(filtered.outfile)
    def hvgs = CHOOSE_RNA_HVGS_SE(normalized.outfile)
    def sumPlot = PLOT_COLDATA_SUM(qc.outfile, 'sum', params.plot_qc_sum_width, params.plot_qc_sum_height)
    def detectedPlot = PLOT_COLDATA_DETECTED(qc.outfile, 'detected', params.plot_qc_detected_width, params.plot_qc_detected_height)

    publish:
    normalized_h5ad = normalized.outfile
    hvgs = hvgs.hvgs
    qc_table = qc.qc_table
    sum_plot = sumPlot.outfile
    detected_plot = detectedPlot.outfile
}

output {
    normalized_h5ad {
        path 'normalized/h5ad'
        mode 'copy'
    }
    hvgs {
        path 'hvgs'
        mode 'copy'
    }
    qc_table {
        path 'qc/tables'
        mode 'copy'
    }
    sum_plot {
        path 'qc/plot_sum'
        mode 'copy'
    }
    detected_plot {
        path 'qc/plot_detected'
        mode 'copy'
    }
}
