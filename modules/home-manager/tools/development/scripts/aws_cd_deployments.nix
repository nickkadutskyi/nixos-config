{ pkgs, ... }:
pkgs.writeShellScriptBin "aws_cd_deployments"
  # bash
  ''
    AWS=${pkgs.awscli2}/bin/aws
    JQ=${pkgs.jq}/bin/jq
    CSVLOOK=${pkgs.csvkit}/bin/csvlook
    $AWS deploy batch-get-deployments \
      --deployment-ids $($AWS deploy list-deployments --query 'deployments' --output json --max-items 10 |
        $JQ -r 'join(" ")') \
      --query 'deploymentsInfo[*].[deploymentId, status, applicationName, creator, createTime, completeTime,
              revision.s3Location.key]' \
      --output json |
      $JQ -r 'def format_date: if . then split("T") | (.[0] | split("-") | .[1] | tonumber) as $month |
              (.[0] | split("-") | .[2] | tonumber) as $day | (.[0] | split("-") | .[0][-2:] | tonumber) as $year |
              (.[1] | split(".") | .[0]) as $time | "\($month)/\($day)/\($year) \($time)" else "N/A" end;
              [ ["ID", "Status", "App", "Initiated", "Started", "Ended", "Revision"] ] +
              (sort_by(.[4]) | reverse | map([.[0], .[1], .[2], .[3], (.[4] | format_date), (.[5] | format_date), .[6]])) |
              map(@tsv) | .[]' |
      $CSVLOOK --tabs -I 2>/dev/null
  ''
