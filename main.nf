// Include modules
include { READ_10X_COUNTS_MTX } from './modules/read-10x-counts-mtx.nf'
include { READ_10X_COUNTS_H5 } from './modules/read-10x-counts-h5.nf'
include { RNA_QC } from './modules/rna-qc.nf'
include { SCE_FILTER } from './modules/sce-filter.nf'
include { PLOT_COLDATA as PLOT_COLDATA_SUM } from './modules/plot-coldata.nf'
include { PLOT_COLDATA as PLOT_COLDATA_DETECTED } from './modules/plot-coldata.nf'

/*
* Pipeline parameters
*/
params {
    input_type: String = 'mtx'
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
    coldata_filter: String = ' '
}

workflow {

    main:
    def meta = [id: params.sample_name]
    def counts

    if( params.input_type == 'mtx' ) {
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

    def qc = RNA_QC(counts.outfile, params.mitochondrial_prefix, params.mitochondrial_threshold)
    def filtered = SCE_FILTER(qc.outfile, ' ', params.coldata_filter)
    def sumPlot = PLOT_COLDATA_SUM(qc.outfile, 'sum', params.plot_qc_sum_width, params.plot_qc_sum_height)
    def detectedPlot = PLOT_COLDATA_DETECTED(qc.outfile, 'detected', params.plot_qc_detected_width, params.plot_qc_detected_height)

    publish:
    filtered_h5ad = filtered.outfile
    qc_table = qc.qc_table
    sum_plot = sumPlot.outfile
    detected_plot = detectedPlot.outfile
}

output {
    filtered_h5ad {
        path 'qc/h5ad'
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
