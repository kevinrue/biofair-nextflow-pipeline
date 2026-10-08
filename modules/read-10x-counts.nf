// Mode-specific wrappers for the optional inputs declared by the
// DropletUtils BiocJobs read-10x-counts job.

process READ_10X_COUNTS_MTX {
    tag "${meta.id}"
    container 'ghcr.io/kevinrue/dropletutils:devel'
    cpus 1
    memory '4 GB'
    disk '10 GB'

    input:
    tuple val(meta), path(mtx_file), path(barcodes_file), path(features_file)
    val sample_name

    output:
    tuple val(meta), path('outfile.h5'), emit: outfile

    script:
    """
    Rscript -e 'BiocJobs::execJob("DropletUtils", "read-10x-counts")' \\
        --mtx_file '${(mtx_file as String).replace("'", "'\\''")}' \\
        --barcodes_file '${(barcodes_file as String).replace("'", "'\\''")}' \\
        --features_file '${(features_file as String).replace("'", "'\\''")}' \\
        --type 'mtx' \\
        --sample_name '${(sample_name as String).replace("'", "'\\''")}' \\
        --outfile 'outfile.h5'
    """

    stub:
    """
    touch 'outfile.h5'
    """
}

process READ_10X_COUNTS_HDF5 {
    tag "${meta.id}"
    container 'ghcr.io/kevinrue/dropletutils:devel'
    cpus 1
    memory '4 GB'
    disk '10 GB'

    input:
    tuple val(meta), path(hdf5_file)
    val sample_name

    output:
    tuple val(meta), path('outfile.h5'), emit: outfile

    script:
    """
    Rscript -e 'BiocJobs::execJob("DropletUtils", "read-10x-counts")' \\
        --hdf5_file '${(hdf5_file as String).replace("'", "'\\''")}' \\
        --type 'hdf5' \\
        --sample_name '${(sample_name as String).replace("'", "'\\''")}' \\
        --outfile 'outfile.h5'
    """

    stub:
    """
    touch 'outfile.h5'
    """
}
