// Include modules
include { READ_10X_COUNTS_MTX; READ_10X_COUNTS_HDF5 } from './modules/read-10x-counts.nf'

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
    if( params.input_type == 'mtx' ) {
        if( !params.mtx_file || !params.barcodes_file || !params.features_file ) {
            error "For input_type 'mtx', provide --mtx_file, --barcodes_file, and --features_file."
        }
        READ_10X_COUNTS_MTX(
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
        READ_10X_COUNTS_HDF5(
            Channel.of(tuple(meta, file(params.hdf5_file))),
            params.sample_name
        )
    }
    else {
        error "Unsupported input_type '${params.input_type}'. Choose 'mtx' or 'hdf5'."
    }
}
