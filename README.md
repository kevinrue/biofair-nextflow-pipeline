# BioFAIR Nextflow pipeline

This pipeline processes a single 10x Genomics single-cell RNA-seq sample. It imports counts, performs RNA quality control, and produces a QC summary plot.

## Workflow

For each run, the pipeline:

1. Imports 10x counts with `DropletUtils`, from either Matrix Market files or a 10x HDF5 file.
2. Runs the `scrapper` RNA QC job using the configured mitochondrial-gene prefix and outlier threshold.
3. Creates a `scater` PDF plot using the configured QC column and dimensions.

The import, QC, and plotting tasks run in their respective DropletUtils, scrapper, and scater containers.

## Inputs and parameters

Choose one input format for each run. `input_type` defaults to `mtx`.

| Parameter | Required for | Description |
| --- | --- | --- |
| `--input_type` | Optional | Input format: `mtx` (default) or `hdf5`. |
| `--matrix_file` | `mtx` | Matrix Market count matrix. |
| `--barcodes_file` | `mtx` | Cell barcodes TSV file. |
| `--features_file` | `mtx` | Feature annotations TSV file. |
| `--hdf5_file` | `hdf5` | 10x HDF5 count file. |
| `--sample_name` | Optional | Sample identifier used for task labels; defaults to `my_sample`. |

Only provide the input file parameters for the selected format. All selected files must exist and be readable by Nextflow.

## Outputs

Nextflow publishes the final results under `results/`:

| Path | Contents |
| --- | --- |
| `results/qc/h5ad/` | QC-filtered AnnData (`.h5ad`) file. |
| `results/qc/tables/` | QC metrics table (`qc_table.tsv`). |
| `results/qc/plots/` | PDF plot of the `sum` QC column. |

Intermediate imported count files are retained in the Nextflow `work/` directory and are passed directly to the QC stage.

## Development container

The development container uses Docker-in-Docker so Nextflow task containers can bind-mount the pipeline work directory. Rebuild the development container after pulling this configuration before running the pipeline. Docker images and containers created from the development container are isolated from the host Docker daemon.

## Example usage

### Matrix Market input

Provide all three files:

```bash
nextflow run main.nf -with-docker \
  --input_type mtx \
  --matrix_file data/matrix.mtx.gz \
  --barcodes_file data/barcodes.tsv.gz \
  --features_file data/features.tsv.gz \
  --sample_name test_sample
```

### HDF5 input

Provide the 10x HDF5 file:

```bash
nextflow run main.nf -with-docker \
  --input_type hdf5 \
  --hdf5_file data/sce.h5 \
  --sample_name test_sample
```

Specify `--input_type hdf5` when using a 10x HDF5 input; otherwise, the Matrix Market input mode is used by default.
