# Paths
PROTO_DIR=proto
MATCH_PROTO=$(PROTO_DIR)/match.proto
SCORE_PROTO=$(PROTO_DIR)/score.proto

# sqlc config
SQLC_MATCH=match-service/db/sqlc.yaml
SQLC_SCORE=score-service/db/sqlc.yaml

# Migration paths
MIGRATIONS_MATCH=migrations/match
MIGRATIONS_SCORE=migrations/score

# Docker
COMPOSE=docker-compose

# Binaries
PROTOC_GEN_GO=protoc-gen-go
PROTOC_GEN_GRPC=protoc-gen-go-grpc

.PHONY: all proto sqlc migrate-up migrate-down test run lint

all: proto sqlc

proto:
	@echo "🚀 Generating gRPC code..."
	protoc --go_out=. --go-grpc_out=. \
		--proto_path=$(PROTO_DIR) \
		$(MATCH_PROTO) $(SCORE_PROTO)

sqlc:
	@echo "📜 Generating sqlc code..."
	sqlc generate -f $(SQLC_MATCH)
	sqlc generate -f $(SQLC_SCORE)

migrate-up:
	@echo "🛠️ Running all migrations..."
	migrate -path $(MIGRATIONS_MATCH) -database 'postgres://postgres:yourpassword@localhost:5432/football?sslmode=disable' up
	migrate -path $(MIGRATIONS_SCORE) -database 'postgres://postgres:yourpassword@localhost:5432/football?sslmode=disable' up

# Reverting all migrations for both match and score databases
migrate-down:
	@echo "⏪ Reverting all migrations..."
	migrate -path $(MIGRATIONS_MATCH) -database 'postgres://postgres:yourpassword@localhost:5432/football?sslmode=disable' down
	migrate -path $(MIGRATIONS_SCORE) -database 'postgres://postgres:yourpassword@localhost:5432/football?sslmode=disable' down

test:
	@echo "🧪 Running tests..."
	go test ./... -v

lint:
	@echo "🔍 Running golangci-lint..."
	golangci-lint run ./...

run-match:
	@echo "🏃 Starting Match Service..."
	go run match-service/main.go

run-score:
	@echo "🏃 Starting Score Service..."
	go run score-service/main.go

up:
	@echo "🐳 Spinning up Docker infra..."
	$(COMPOSE) up -d

down:
	@echo "🧼 Shutting down Docker infra..."
	$(COMPOSE) down
