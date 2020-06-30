# How to run migrations with Flyway

```
s3 sync migrations s3://stacklight-config-20200611/sql (or vice versa)
docker run --rm --network intranet -v `pwd`/sql:/flyway/sql flyway/flyway -user=flyway -password=xxxxxxxx -url=jdbc:postgresql://db/stacklight_stage migrate
```