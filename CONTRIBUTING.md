# Contributing

Thanks for your interest in contributing to the BioFAIR Nextflow pipeline.

## Before you start

- For a substantial change, open an issue first to discuss the proposed approach.
- Keep pull requests focused, and update the README when a change affects pipeline behavior, parameters, inputs, or outputs.
- Do not commit generated run files from `.nextflow/`, `work/`, `results/`, or `.nextflow.log*`.
- The modules in `modules/` are copied from upstream Bioconductor-related repositories. Do not edit them manually; any change should be made through the upstream package to update all wrappers via the BiocJobs action.

## Adding or updating a module

The [BiocJobs developer guide](https://github.com/almahmoud/BiocJobs/blob/main/docs/developer-guide.md) describes the step-by-step process from writing the pair of YAML file and R script required for each module to the generation of the wrappers themselves, including the Nextflow module file.

Primarily addressed to the maintainer of the relevant Bioconductor package, the main thing it doesn't mention is the need to first clone the repository of the package locally, to add, edit, and commit the necessary files.

## Running the pipeline tests

The CI workflow runs both supported input modes with Nextflow and Docker. To run the same checks locally, install Nextflow and Docker, then run these commands from the repository root:

```bash
nextflow run main.nf -with-docker -params-file params/mtx.yml
nextflow run main.nf -with-docker -params-file params/hdf5.yml
```

The parameter files refer to example input data and metadata filters in the repository. If you change the pipeline, test both modes when the change could affect either one. Check that the expected outputs are produced under `results/`.

## Submitting a pull request

1. Create a branch for your change.
2. Make the change and run the relevant pipeline checks.
3. Open a pull request describing the motivation, the changes made, and the checks you ran. Include or link any related issue.
4. Respond to review feedback and update the pull request as needed.