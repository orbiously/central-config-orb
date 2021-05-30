CheckEnv() {
  if [ -z "${GH_TOKEN:-}" ]; then
    echo "In order to use the Config dispatcher orb, an OAuth token must be present via the GH_TOKEN environment variable."
    echo "See instructions in the GitHub documentation: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-tokenp"
    exit 1
  fi

  if [ ! -s ${TARGETS_LIST} ]; then
    echo "Target file is empty. Please add at least 1 target repository"
    exit 1
  fi

  if [ $(git hash-object ${CENTRAL}) = $(git hash-object $HOME/project/.circleci/config.yml) ]; then
    echo "The configuratio file you're deploying can't be the same as this build's confguration file"
    echo "Check the content of the configuration file you're trying to deploy"
    exit 1
  fi

  if [ "${SKIP}" == "1" ]; then
    echo "Build(s) will be skipped in target project(s)"
    MESSAGE="Global config update [skip ci]"
  else
    printf "This config update will trigger builds in target project(s)\n"
    MESSAGE="Global config update"
  fi
}

DispatchConf() {
  touch /tmp/deployment.log
  GLOBAL_64="$(cat ${CENTRAL} | base64 -w 0)"
while read -r target
  do
    REPO=$(jq -r '."target-repo"' \<<< $target)
    BRANCH=$(jq -r '."target-branch"' \<<< $target)

    if [ $(curl -s -w '%{response_code}' --output /dev/null --location --request GET "https://api.github.com/repos/$REPO/contents/.circleci/config.yml?ref=$BRANCH" --header "Authorization: token $GH_TOKEN" --header "Accept: application/vnd.github.v3+json") != 200 ]; then
      curl -s -w '%{response_code}' -X PUT https://api.github.com/repos/$REPO/contents/.circleci/config.yml -H "Authorization: token $GH_TOKEN" -H 'Accept: application/vnd.github.v3+json' -d '{"message":"'"$MESSAGE"'","content":"'"$GLOBAL_64"'","branch":"'"$BRANCH"'"}' > /tmp/response.status

      if [[ "$(cat /tmp/response.status)" = "200" ]]; then
        printf "\n${CENTRAL} was successfully deployed to $REPO [branch: $BRANCH\n"
      fi
    else
      BLOB_SHA=$(curl -s --location --request GET "https://api.github.com/repos/${REPO}/contents/.circleci/config.yml?ref=${BRANCH}" --header "Authorization: token ${GH_TOKEN}" --header "Accept: application/vnd.github.v3+json"|jq -r .sha)

      if [ $(git hash-object ${CENTRAL}) != $BLOB_SHA ] || [ "${FORCE}" == "1" ]; then
        curl -s -o /dev/null -w '%{response_code}' -X PUT https://api.github.com/repos/$REPO/contents/.circleci/config.yml --header "Authorization: token ${GH_TOKEN}" --header "Accept: application/vnd.github.v3+json" --data-raw '{"message":"'"$MESSAGE"'","content":"'"${GLOBAL_64}"'","sha": "'"$BLOB_SHA"'","branch":"'"$BRANCH"'"}' > /tmp/response.status
                        
        if [[ "$(cat /tmp/response.status)" = "200" ]]; then
          printf "\n${CENTRAL} was successfully deployed to $REPO [branch: $BRANCH]\n" | tee -a /tmp/deployment.log
        fi
      else
        printf "\nThe same version of the configuration file already exists in [branch: $BRANCH]\n"
      fi
    fi  
  done \<<< $(jq -c < "${TARGET_LIST}")
}

CheckEnv
DispatchConf
