// Include modules
include { READ_10X_COUNTS } from './modules/read-10x-counts.nf'

/*
* Pipeline parameters
*/
params {
    mtx_file: Path = 'data/matrix.mtx.gz'
    barcodes_file: Path = 'data/barcodes.tsv.gz'
    features_file: Path = 'data/features.tsv.gz'
    hdf5_file: Path = 'data/sce.h5'
    sample_name: String = 'my_sample'
}

workflow {

    main:
    // emit a greeting
    def meta = [id: params.sample_name]
    def input = Channel.of(tuple(
        meta,
        file(params.mtx_file),
        file(params.barcodes_file),
        file(params.features_file),
        file(params.hdf5_file)
    ))
    READ_10X_COUNTS(input, 'mtx', params.sample_name)
}
