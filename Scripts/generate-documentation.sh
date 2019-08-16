#!/bin/bash

# Set the output directory
outdir=${1:-gh-pages}

################################################################################
# Change directory to repository root
################################################################################

pushd `dirname $0` > /dev/null
root=`pwd`
popd > /dev/null
cd $root
cd ..

################################################################################
# Run Jazzy to generate documentation
################################################################################

  xcodebuild_arguments=-project,RestKit.xcodeproj,-scheme,RestKit
  jazzy \
    --module RestKit \
    --xcodebuild-arguments $xcodebuild_arguments \
    --output ${outdir} \
    --clean \
    --readme README.md \
    --documentation README.md \
    --github_url https://github.com/watson-developer-cloud/restkit \
    --copyright "&copy; IBM Corp. 2016-$(date +%Y). (Last updated: $(date +%Y-%m-%d))" \
    --hide-documentation-coverage
done

################################################################################
# Generate index.html and copy supporting files
################################################################################

(
  version=$(git describe --tags)
  cat Scripts/generate-documentation-resources/index-prefix | sed "s/SDK_VERSION/$version/"
  for service in ${services[@]}; do
    echo "<li><a target="_blank" href="./services/${service}/index.html">${service}</a></li>"
  done
  echo -e "          </section>\n        </section>"
  sed -n '/<section id="footer">/,/<\/section>/p' ${outdir}/services/${services[0]}/index.html
  cat Scripts/generate-documentation-resources/index-postfix
) > ${outdir}/index.html

cp -r Scripts/generate-documentation-resources/* ${outdir}
rm ${outdir}/index-prefix ${outdir}/index-postfix

################################################################################
# Collect undocumented.json files
################################################################################

declare -a undocumenteds
undocumenteds=($(ls -r ${outdir}/services/*/undocumented.json))

(
  echo "["
  if [ ${#undocumenteds[@]} -gt 0 ]; then
    echo -e -n "\t"
    cat "${undocumenteds[0]}"
    unset undocumenteds[0]
    for f in "${undocumenteds[@]}"; do
      echo ","
      echo -e -n "\t"
      cat "$f"
    done
  fi
  echo -e "\n]"
) > ${outdir}/undocumented.json
