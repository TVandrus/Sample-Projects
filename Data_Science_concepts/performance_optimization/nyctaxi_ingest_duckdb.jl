using DuckDB, DataFrames, Parquet, SQLite
using BenchmarkTools 

pwd()
cd("S:/nyctaxi_raw")
readdir()

l = readdir()[2]
con = DBInterface.connect(DuckDB.DB, ":memory:")
x = DBInterface.execute(con, "select * from '$l' limit 5")
x.names
y = DataFrame(x)
n = DBInterface.execute(con, "select count(*) as n from '$l'").tbl.n

@btime begin 
    l = readdir()
    l = l[[f[1:15] == "yellow_tripdata" for f in l]]
    l = l[[f[1:20] >= "yellow_tripdata_2022" for f in l]]
    tbl = DataFrame([:fname=>"file"::String, :n=>0::Number])
    con = DBInterface.connect(DuckDB.DB, ":memory:")
    for f in l
        q = DBInterface.execute(con, "select count(*) as n from '$f'")
        print(q);
        append!(tbl::DataFrame, [
            :fname => f[17:23],
            :n =>  q.tbl.n
            ]
        )
    end
    tbl
    print(sum(tbl.n))
end

# ~732M records from yellow taxis 2015-2024Q2





db = SQLite.DB("nyctaxi_raw_sqlite_jl.db")
tname = "nyctaxi_src"
DBInterface.execute(db, "drop table $tname")
DBInterface.execute(db,
"""CREATE TABLE "$tname" (
    "tpep_pickup_datetime" TEXT,
    "tpep_dropoff_datetime" TEXT,
    "trip_distance" REAL,
    "PULocationID" INT,
    "DOLocationID" INT,
    "fare_amount" REAL,
    "total_amount" REAL
);""")

@btime begin 
    l = readdir()
    l = l[[f[1:15] == "yellow_tripdata" for f in l]]
    l = l[[f[1:20] >= "yellow_tripdata_2022" for f in l]]
    con = DBInterface.connect(DuckDB.DB, ":memory:")
    for f in l
        tbl = DataFrame(
            DBInterface.execute(con, "select 
            tpep_pickup_datetime,
            tpep_dropoff_datetime,
            trip_distance,
            PULocationID,
            DOLocationID,
            fare_amount,
            total_amount
            from '$f'"
            )
        )
        tbl |> SQLite.load!(db, tname)
        print("\n", f, "\n")
        print(DBInterface.execute(db, "select count(*) as n from $tname;"))
    end
end
