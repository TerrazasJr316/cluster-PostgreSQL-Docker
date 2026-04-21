# 🐘 PostgreSQL Cluster with Docker
This project uses Docker and Docker Compose to orchestrate a PostgreSQL cluster, consisting of one primary node and two replicas in *streaming replication* mode. The goal is to provide a high-availability database environment with read-scaling capabilities, ideal for development and testing.

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white&labelColor=101010)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white&labelColor=101010)](https://docs.docker.com/compose/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white&labelColor=101010)](https://www.postgresql.org/)

## 🎯 Features

*   **1 Primary + 2 Replicas Cluster:** High-availability setup with a master node for writes and two replica nodes for reads.
*   **Streaming Replication:** Asynchronous physical replication to keep replicas updated with the primary.
*   **Replication Slots:** Ensures the primary does not delete WAL segments before they have been consumed by all replicas, preventing them from going out of sync.
*   **Automated Initialization:** Scripts to automatically set up the replication user on the primary and clone the database on the replicas at startup.
*   **Data Persistence:** Use of Docker volumes to ensure data persists across container restarts.
*   **Flexible Configuration:** Parameterization through an `.env` file for easy configuration of credentials and ports.

## 🛠️ Technologies Used

*   **Orchestration:** Docker, Docker Compose
*   **Database:** PostgreSQL 16
*   **Scripting:** Bash/Shell

## 📦 Installation and Configuration

### Requirements

*   Docker
*   Docker Compose

### 1. Clone the repository

```bash
git clone https://github.com/TerrazasJr316/cluster-PostgreSQL-Docker.git
cd cluster-PostgreSQL-Docker
```

### 2. Create the configuration file

Create a `.env` file in the project root.

```bash
touch .env
```

Open the `.env` file and customize the variables:

```dotenv
# Credentials for the main database user

# Credentials for the replication user
```

### 3. Start the cluster

Run the following command to build and start the containers in the background.

```bash
docker-compose up -d
```

### 4. Connecting to the Cluster

Once the containers are running, you can connect to each node:

*   **Primary Node (Read/Write):** `localhost:5432` (or the port you configured in `DB_PORT`).
*   **Replica 1 (Read-Only):** `localhost:5434`
*   **Replica 2 (Read-Only):** `localhost:5435`

You can verify the cluster status with:

```bash
docker-compose ps
```

## ⚙️ Cluster Architecture

The `docker-compose.yml` defines three PostgreSQL services:

*   **`postgres_1` (Primary):** The only node that accepts write operations. On startup, it creates a replication user and replication slots for the replica nodes. Changes are written to the *Write-Ahead Log* (WAL).
*   **`postgres_2` and `postgres_3` (Replicas):** These are *Hot Standby* nodes. On startup, they clone the database from the primary node using `pg_basebackup`. They then connect to the primary and receive changes via *streaming replication*, applying WAL records to stay in sync. They serve read-only queries, distributing the load.

*Replication slots* guarantee that the primary will not recycle WAL files until all replicas have confirmed receipt, preventing sync errors if a replica temporarily disconnects.

## 📁 Project Structure

```bash
cluster-PostgreSQL-Docker/
├── docker-compose.yml  # Cluster service orchestration
├── init_postgres.sh    # Initialization script for the primary node
├── init_rep.sh         # Initialization script for the replica nodes
└── README.md           # This file
```

## 🐛 Troubleshooting

*   **Check logs:** If a container does not start correctly, review its logs.
```bash
    # View logs for all services
    docker-compose logs -f

    # View logs for a specific service (e.g. replica 2)
    docker-compose logs -f postgres_3
```
*   **Replica connection failure:** Make sure the credentials (`REPLICA_USER`, `REPLICA_PASSWORD`) in your `.env` file are correct and that the primary node (`postgres_1`) is healthy (`docker-compose ps`). The replica script will automatically retry the connection if the primary is not ready yet.

## ❓ FAQ

*   **How do I test replication?**
    You can test the replication by writing data to the primary node and then reading it from a replica.

    1.  **Connect to the Primary Node (`postgres_1`)**

        Open your terminal and run this command to access the interactive `psql` console in the primary container.
        ```bash
        docker exec -it postgres_1 psql -U ${POSTGRES_USER} -d ${DB_NAME}
        ```
        *Note: You might need to replace `${POSTGRES_USER}` and `${DB_NAME}` with the actual values from your `.env` file.*

    2.  **Create a Table and Insert Data**

        Inside the `psql` console, create a test table and insert a row:
        ```sql
        CREATE TABLE users_test (
            id SERIAL PRIMARY KEY,
            username VARCHAR(50) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        INSERT INTO users_test (username) VALUES ('test_user_from_primary');
        ```
        You should see `CREATE TABLE` and `INSERT 0 1` confirmations. Type `\q` and press Enter to exit.

    3.  **Connect to a Replica (`postgres_2`)**

        Now, connect to a replica to verify that the data was replicated.
        ```bash
        docker exec -it postgres_2 psql -U ${POSTGRES_USER} -d ${DB_NAME}
        ```

    4.  **Verify Replication and Read-Only Mode**

        Inside the replica's `psql` console, query the table:
        ```sql
        SELECT * FROM users_test;
        ```
        You will see the data you inserted on the primary node. Now, try to write to the replica:
        ```sql
        INSERT INTO users_test (username) VALUES ('trying_to_write_on_replica');
        ```
        The database will stop you with an error, confirming that replicas are read-only:
        `ERROR: cannot execute INSERT in a read-only transaction`

        This confirms your cluster is working correctly. Type `\q` to exit.

*   **What is Streaming Replication?**
    It is a replication method in PostgreSQL where standby servers (replicas) connect to the primary and receive WAL changes in near real-time.

*   **Why use Replication Slots?**
    A replication slot is a guarantee that the primary server will retain the WAL segments needed by a replica, even if it disconnects. Without slots, the primary could recycle a WAL file that a replica has not yet processed, causing replication to break permanently.

## ✉️ Contact and Social Media

### 💻 Computer Systems Engineering

Adaptable and flexible in different work environments, with strong critical thinking, solid problem-solving skills, and a collaborative, responsible mindset. My strongest areas are backend development, databases, and machine learning.

If you find this project useful, you can support it by giving a "☆ Star" to the repository.

![Email](https://img.shields.io/badge/Gmail-terrazasjosue0%40gmail.com-EA4335?style=for-the-badge&logo=Gmail&logoColor=white&labelColor=101010)
[![Facebook](https://img.shields.io/badge/Facebook-%40Josu%C3%A9_Terrazas-0866FF?style=for-the-badge&logo=Facebook&logoColor=withe&labelColor=101010)](https://facebook.com/josue.terrazasmendoza)
[![Instagram](https://img.shields.io/badge/Instagram-%40jos__mdz316-E4405F?style=for-the-badge&logo=Instagram&logoColor=white&labelColor=101010)](https://instagram.com/jos_mdz316/)