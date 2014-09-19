sh "curl https://sdk.cloud.google.com | bash"
sh "gcloud auth login"
project = ENV['GCE_PROJECT_NAME']
zone = ENV['GCE_ZONE_NAME']
sh "gcloud config set project #{project or "asia-east1"}"
sh "gcloud config set project #{zone or "asia-east1-b"}"
