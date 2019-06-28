# Dockerised Apache Druid cluster

This project demostrates how you can setup a Dockerized example/development [Apache Druid](http://druid.io/) cluster.


The cluster is being composed of the following components:

- S3 Compatible Object Storage [**MinIO**](https://min.io) for Deep storage
- [**PostgreSQL**](https://www.postgresql.org/) for metadata storage 
- [**Zookeeper**](https://zookeeper.apache.org/) for internal service discovery, coordination, and leader election
- [**Apache Druid**](http://druid.io/) platform:
  
  * **Middle Manager** to handle the ingestion of data into the cluster
  * **Historical** to handle the storage and querying on “historical” data
  * **Broker** to receive queries from external clients
  * **Coordinator** to assign segments to Historical nodes
  * **Overlord** to assign ingestion tasks to Middle Managers and to coordinate segment publishing
  * **Router** provides a unified API gateway in front of Brokers, Overlords and Coordinators

### Instructions to build Druid image

```
make image
```

or by using docker-compose

```
docker-compose build
```

You can also specify the version of Druid to build, for example:

```
make DRUID_VERSION=0.14.1-incubating image
```

or by using docker-compose

```
docker-compose build --build-arg ARG_DRUID_VERSION=0.14.1-incubating
```

### Run the cluster

```
docker-compose up
```

or to run in the backgroumd:

```
docker-compose up -d
```

After a while the Druid console should be available in [http://localhost:8888](http://localhost:8888)


### Load example data

For example data we are using a subset of the [NYC Taxi & Limousine Commission - Trip Record Data](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page), specifically from months 2015-01 to 2015-03.

```
cd dataset
./03-load_to_druid.sh
```

Please note that you can download data for different months and adjust the sample size by adjusting the parameters of `./dataset/01-download.sh` and `./dataset/02-create_sample_tripdata.sh`.

The schema of the dataset and the indexing task is being defined in `./dataset/yellow_tripdata-index.json`

...enjoy :)