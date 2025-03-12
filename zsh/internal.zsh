function k8s-get-config {
    export DEV_PROJECT=sunrise-dev-0224
    export PROD_PROJECT=sunrise-prod-0224
    gcloud container clusters get-credentials duploinfra-onerise --region asia-southeast1 --project $DEV_PROJECT
    gcloud container clusters get-credentials duploinfra-threerise --region asia-southeast1 --project $DEV_PROJECT
    gcloud container clusters get-credentials duploinfra-tworise --region asia-southeast1 --project $DEV_PROJECT

    gcloud container clusters get-credentials duploinfra-staging --region us-central1 --project $DEV_PROJECT
    gcloud container clusters get-credentials duploinfra-dev --region us-central1 --project $DEV_PROJECT
    gcloud container clusters get-credentials duploinfra-appprod --region us-central1 --project $PROD_PROJECT
    gcloud container clusters get-credentials duploinfra-drgnprod --region us-central1 --project $PROD_PROJECT
}

# Replace "my_env_name" with your Conda environment name
conda_env_name="sunrise"
core_project_path="$HOME/Projects/core"

# Function to check if inside core_project_path and activate Conda environment
function auto_conda_activate {
    if [[ $PWD == $core_project_path* ]]; then
        # Check if the environment is not already active
        if [[ "$CONDA_DEFAULT_ENV" != "$conda_env_name" ]]; then
            echo "Activating Conda environment: $conda_env_name"
            # export PATH=/opt/homebrew/Caskroom/miniconda/base/envs/sunrise/bin:$PATH
            conda activate $conda_env_name
        fi

        # set up the environment variables
        export PYTHONWARNINGS="ignore"
        export GIT_COMMIT_HASH=$(git rev-parse HEAD)
        export LOCALDEV=true
        export PROD_INFERENCE_SERVER_HOST=https://vllm-appprod.tail435eb.ts.net/v1
        export DEDICATED_INFERENCE_SERVER_HOST=https://vllm-staging.tail435eb.ts.net/v1
        export DEFAULT_MODEL_NAME=registry/model-research-default-qwen25-eea75
        export ENCODER_SERVER_HOST=encoder-staging.tail435eb.ts.net

        function autoformat() {      
          pushd $(git rev-parse --show-toplevel)
          make autoformat            
          popd                       
        }
    else
        # Deactivate Conda environment if leaving the core project
        if [[ "$CONDA_DEFAULT_ENV" == "$conda_env_name" ]]; then
            conda deactivate
        fi
    fi
}

# Hook to trigger on directory change
autoload -Uz add-zsh-hook
add-zsh-hook chpwd auto_conda_activate

auto_conda_activate