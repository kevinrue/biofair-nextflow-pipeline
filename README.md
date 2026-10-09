# BioFAIR Nextflow pipeline

This pipeline reads 10x Genomics count data with `DropletUtils::read10xCounts` and writes `outfile.h5` in the Nextflow task work directory.

Choose one input format for each run. Paths are supplied with `--mtx_file`, `--barcodes_file`, and `--features_file` for Matrix Market input, or with `--hdf5_file` for HDF5 input. Unspecified file parameters default to `null`; only the parameters required by the selected input type need to be provided.

## Matrix Market input

Provide all three files:

```bash
nextflow run main.nf -with-docker \
  --input_type mtx \
  --mtx_file data/matrix.mtx.gz \
  --barcodes_file data/barcodes.tsv.gz \
  --features_file data/features.tsv.gz \
  --sample_name my_sample
```

## HDF5 input

Provide the 10x HDF5 file:

```bash
nextflow run main.nf -with-docker \
  --input_type hdf5 \
  --hdf5_file data/sce.h5 \
  --sample_name my_sample
```

The pipeline defaults `input_type` to `mtx`; specify `--input_type hdf5` when using the HDF5 input. The selected input file or files must exist and be readable by Nextflow.
