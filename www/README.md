
# Run locally

## Prepare DB
    % mongod &
    % find output/json -name law.json -exec mongoimport -d db -c law --upsert --upsertFields name {} \;

## Run HTTP frontend
    % npm run prepublish && node app.js
