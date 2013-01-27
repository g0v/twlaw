
# Run locally

## Prepare DB
    % mongod &
    % find output/json -name law.json -exec mongoimport -d db -c law --upsert --upsertFields name {} \;

## Run HTTP frontend
    % npm run prepublish && node app.js


# Push local db to production
mongodump -d db &&
mongorestore -h ds049237.mongolab.com:49237 -d twlaw -u admin -p $PASSWD dump/db --drop
