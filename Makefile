.PHONY: all rootca intermediateca server certchain build run logs login clean

# 各証明書作成〜検証までを実行
all: rootca intermediateca server certchain build verify

# ルートCAの秘密鍵生成
.keys/rootCA.key:
	mkdir .keys
	openssl genpkey -algorithm RSA -out .keys/rootCA.key

# ルート証明書の作成要求 (CSR)
.keys/rootCA.csr: .keys/rootCA.key
	openssl req -new -key .keys/rootCA.key -out .keys/rootCA.csr -subj "/C=JP/ST=Tokyo/L=Chiyoda-ku/O=MyOrg/OU=MyUnit/CN=RootCA"

# ルート証明書の生成
.keys/rootCA.crt: .keys/rootCA.csr
	echo "basicConstraints=CA:TRUE" > .keys/rootCA_extfile.cnf
	openssl x509 -req -days 3650 -in .keys/rootCA.csr -signkey .keys/rootCA.key -out .keys/rootCA.crt -extfile .keys/rootCA_extfile.cnf
	rm .keys/rootCA_extfile.cnf

# ルートCAのターゲット
rootca: .keys/rootCA.key .keys/rootCA.csr .keys/rootCA.crt

# 中間証明書用の秘密鍵の生成
.keys/intermediateCA.key:
	openssl genpkey -algorithm RSA -out .keys/intermediateCA.key

# 中間証明書の作成要求 (CSR)
.keys/intermediateCA.csr: .keys/intermediateCA.key
	openssl req -new -key .keys/intermediateCA.key -out .keys/intermediateCA.csr -subj "/C=JP/ST=Tokyo/L=Chiyoda-ku/O=MyOrg/OU=MyUnit/CN=IntermediateCA"

# 中間証明書の生成
.keys/intermediateCA.crt: .keys/intermediateCA.csr .keys/rootCA.crt .keys/rootCA.key
	echo "basicConstraints=CA:TRUE" > .keys/intermediateCA_extfile.cnf
	openssl x509 -req -days 1825 -in .keys/intermediateCA.csr -CA .keys/rootCA.crt -CAkey .keys/rootCA.key -CAcreateserial -out .keys/intermediateCA.crt -extfile .keys/intermediateCA_extfile.cnf
	rm .keys/intermediateCA_extfile.cnf

# 中間CAのターゲット
intermediateca: .keys/intermediateCA.key .keys/intermediateCA.csr .keys/intermediateCA.crt

# サーバー証明書用の秘密鍵の生成
.keys/server.key:
	openssl genpkey -algorithm RSA -out .keys/server.key

# サーバー証明書の作成要求 (CSR)
.keys/server.csr: .keys/server.key
	openssl req -new -key .keys/server.key -out .keys/server.csr -subj "/C=JP/ST=Tokyo/L=Chiyoda-ku/O=MyOrg/OU=MyUnit/CN=www.tls-example.com"

# サーバー証明書の生成
.keys/server.crt: .keys/server.csr .keys/intermediateCA.crt .keys/intermediateCA.key
	openssl x509 -req -days 365 -in .keys/server.csr -CA .keys/intermediateCA.crt -CAkey .keys/intermediateCA.key -CAcreateserial -out .keys/server.crt

# サーバー証明書のターゲット
server: .keys/server.key .keys/server.csr .keys/server.crt

# 証明書チェーンの作成（オプション）
.keys/server_chain.crt: .keys/server.crt .keys/intermediateCA.crt
	cat .keys/server.crt .keys/intermediateCA.crt > .keys/server_chain.crt

# 証明書チェーンのターゲット
certchain: .keys/server_chain.crt

# ビルド
build: rootca intermediateca server certchain
	docker compose build

# サーバー起動
run: build
	docker compose up -d

# リアルタイムログ出力
logs:
	docker compose logs -f

# クライアントログイン
login: run
	docker compose exec -it client bash

# 証明書チェーン検証
verify: run
	docker compose exec client bash -c "openssl s_client -showcerts -connect www.tls-example.com:443 </dev/null"

# tlsバージョン・暗号スイート確認
list_ciphers: run
	docker compose exec client bash -c "nmap --script ssl-enum-ciphers -p 443 www.tls-example.com"

# 証明書・イメージ・コンテナを削除
clean:
	rm -rf .keys
	docker compose down --rmi all --remove-orphans
