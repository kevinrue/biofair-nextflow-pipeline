// Include modules
include { READ_10X_COUNTS } from './modules/read-10x-counts.nf'

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
    def inputFiles

    if( params.input_type == 'mtx' ) {
        if( !params.mtx_file || !params.barcodes_file || !params.features_file ) {
            error "For input_type 'mtx', provide --mtx_file, --barcodes_file, and --features_file."
        }
        def matrix = file(params.mtx_file)
        inputFiles = tuple(
            meta,
            matrix,
            file(params.barcodes_file),
            file(params.features_file),
            matrix
        )
    }
    else if( params.input_type == 'hdf5' ) {
        if( !params.hdf5_file ) {
            error "For input_type 'hdf5', provide --hdf5_file."
        }
        def hdf5 = file(params.hdf5_file)
        // The generated module declares all four source files as required paths.
        // The HDF5 reader uses hdf5_file; repeat that file in the unused slots
        // so Nextflow can stage the tuple without null path inputs.
        inputFiles = tuple(meta, hdf5, hdf5, hdf5, hdf5)
    }
    else {
        error "Unsupported input_type '${params.input_type}'. Choose 'mtx' or 'hdf5'."
    }

    READ_10X_COUNTS(Channel.of(inputFiles), params.input_type, params.sample_name)
}
