// Include modules
include { READ_10X_COUNTS } from './modules/read-10x-counts.nf'

/*
* Pipeline parameters
*/
params {
    input_type: String = 'mtx'
    mtx_file: Path = 'data/matrix.mtx.gz'
    barcodes_file: Path = 'data/barcodes.tsv.gz'
    features_file: Path = 'data/features.tsv.gz'
    hdf5_file: Path = 'data/sce.h5'
    sample_name: String = 'my_sample'
}

workflow {

    main:
    def meta = [id: params.sample_name]
    def inputFiles

    if( params.input_type == 'mtx' ) {
        inputFiles = tuple(
            meta,
            file(params.mtx_file),
            file(params.barcodes_file),
            file(params.features_file),
            file(params.hdf5_file)
        )
    }
    else if( params.input_type == 'hdf5' ) {
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
