// Include modules
include { READ_10X_COUNTS_MTX } from './modules/read-10x-counts-mtx.nf'
include { READ_10X_COUNTS_H5 } from './modules/read-10x-counts-h5.nf'
include { RNA_QC } from './modules/rna-qc.nf'
// include { PLOT_COLDATA } from './modules/plot-coldata.nf'

/*
* Pipeline parameters
*/
params {
    input_type: String = 'mtx'
    mtx_file: String? = null
    barcodes_file: String? = null
    features_file: String? = null
    hdf5_file: String? = null
    sample_name: String = 'my_sample'
}

workflow {

    main:
    def meta = [id: params.sample_name]
    def counts

    if( params.input_type == 'mtx' ) {
        if( !params.mtx_file || !params.barcodes_file || !params.features_file ) {
            error "For input_type 'mtx', provide --mtx_file, --barcodes_file, and --features_file."
        }
        counts = READ_10X_COUNTS_MTX(
            Channel.of(tuple(
                meta,
                file(params.mtx_file),
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

    def qc = RNA_QC(counts.outfile, 'MT-', 3.0)
    // def plot = PLOT_COLDATA(qc.outfile, 'sum', 3.0, 5.0)

    publish:
    qc_h5ad = qc.outfile
    qc_table = qc.qc_table
    // sum_plot = plot.outfile
}

output {
    qc_h5ad {
        path 'qc/h5ad'
        mode 'copy'
    }
    qc_table {
        path 'qc/tables'
        mode 'copy'
    }
    // sum_plot {
    //     path 'qc/plots'
    //     mode 'copy'
    // }
}
