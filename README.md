# BioFAIR Nextflow pipeline

This pipeline processes a single 10x Genomics single-cell RNA-seq sample. It imports counts, performs RNA quality control, and produces a QC summary plot.

## Workflow

For each run, the pipeline:

1. Imports 10x counts with `DropletUtils`, from either Matrix Market files or a 10x HDF5 file.
2. Runs the `scrapper` RNA QC job using the configured mitochondrial-gene prefix and outlier threshold.
3. Creates a `scater` PDF plot using the configured QC column and dimensions.

The import, QC, and plotting tasks run in their respective DropletUtils, scrapper, and scater containers.

## Inputs and parameters

Choose one input format for each run and explicitly set `input_type` to `mtx` or `hdf5`.

| Parameter | Required for | Description |
| --- | --- | --- |
| `--input_type` | Required | Input format: `mtx` or `hdf5`. |
| `--matrix_file` | `mtx` | Matrix Market count matrix. |
| `--barcodes_file` | `mtx` | Cell barcodes TSV file. |
| `--features_file` | `mtx` | Feature annotations TSV file. |
| `--hdf5_file` | `hdf5` | 10x HDF5 count file. |
| `--sample_name` | Optional | Sample identifier used for task labels; defaults to `my_sample`. |
| `--mitochondrial_prefix` | Optional | Prefix used to identify mitochondrial genes during RNA QC; defaults to `MT-`. |
| `--mitochondrial_threshold` | Optional | Mitochondrial threshold passed to RNA QC; defaults to `3.0`. |
| `--plot_qc_sum_width` | Optional | Width in inches of the QC sum plot PDF; defaults to `3.0`. |
| `--plot_qc_sum_height` | Optional | Height in inches of the QC sum plot PDF; defaults to `5.0`. |
| `--plot_qc_detected_width` | Optional | Width in inches of the QC detected plot PDF; defaults to `3.0`. |
| `--plot_qc_detected_height` | Optional | Height in inches of the QC detected plot PDF; defaults to `5.0`. |
| `--coldata_filter` | Optional | Expression used to filter cells by column metadata; defaults to `detected > 200 & detected < 2500 & subset.proportion.MT < 0.05`. |

Only provide the input file parameters for the selected format. All selected files must exist and be readable by Nextflow.

## Outputs

Nextflow publishes the final results under `results/`:

| Path | Contents |
| --- | --- |
| `results/qc/h5ad/` | QC-filtered AnnData (`.h5ad`) file. |
| `results/qc/tables/` | QC metrics table (`qc_table.tsv`). |
| `results/qc/plot_sum/` | PDF plot of the `sum` QC column. |
| `results/qc/plot_detected/` | PDF plot of the `detected` QC column. |

Intermediate imported count files are retained in the Nextflow `work/` directory and are passed directly to the QC stage.

## Development container

The development container uses Docker-in-Docker so Nextflow task containers can bind-mount the pipeline work directory. Rebuild the development container after pulling this configuration before running the pipeline. Docker images and containers created from the development container are isolated from the host Docker daemon.

## Example usage

### Matrix Market input

Provide all three files in `params/mtx.yml`, then run:

```bash
nextflow run main.nf -with-docker -params-file params/mtx.yml
```

### HDF5 input

Provide the 10x HDF5 file in `params/hdf5.yml`, then run:

```bash
nextflow run main.nf -with-docker -params-file params/hdf5.yml
```

The parameter files include the required input type, file locations, sample name, and filter settings. Copy and edit the appropriate file to configure a run.
