# BioFAIR Nextflow pipeline

This pipeline processes a single 10x Genomics single-cell RNA-seq sample. It imports counts, performs RNA quality control, filters metadata, normalizes counts, selects highly variable genes (HVGs), and runs PCA.

## Workflow

For each run, the pipeline:

1. Imports 10x counts with `DropletUtils`, from either Matrix Market files or a 10x HDF5 file.
2. Runs the `scrapper` RNA QC job using the configured mitochondrial-gene prefix and outlier threshold.
3. Creates QC plots for inspection.
4. Filters row and column metadata using the configured JSON predicates.
5. Normalizes RNA counts with `scrapper`.
6. Selects highly variable genes from the normalized counts.
7. Runs PCA on the normalized counts using the selected HVGs as features, retaining the number of principal components set by `--n_pcs` (default: 25).

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
| `--metadata_filters` | Required | JSON file containing `rowdata` and `coldata` filter trees. Either section can be empty to skip filtering that dimension. The examples use `data/metadata-filters.json`. |
| `--n_pcs` | Optional | Number of principal components to retain in PCA; defaults to `25`. |

Only provide the input file parameters for the selected format. All selected files, including the metadata filter JSON, must exist and be readable by Nextflow. The JSON filter format uses explicit predicate objects; see `data/metadata-filters.json` for the example column filter and an empty row filter.

## Outputs

Nextflow publishes the PCA H5AD, HVG list, and QC branch outputs under `results/`:

| Path | Contents |
| --- | --- |
| `results/pca/h5ad/` | Metadata-filtered, normalized AnnData with PCA results (`.h5ad`) file. |
| `results/hvgs/` | Text file (`hvgs.txt`) listing the selected highly variable genes. |
| `results/qc/tables/` | QC metrics table (`qc_table.tsv`). |
| `results/qc/plot_sum/` | PDF plot of the `sum` QC column. |
| `results/qc/plot_detected/` | PDF plot of the `detected` QC column. |

Intermediate imported counts and the metadata-filtered but unnormalized H5AD remain in the Nextflow `work/` directory. The QC table and plots remain published as branch outputs.

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

The parameter files include the required input type, file locations, sample name, and metadata filter file path. Copy and edit the appropriate file to configure a run. Edit `data/metadata-filters.json` to change row or column filtering.
