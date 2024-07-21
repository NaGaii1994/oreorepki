# オレオレPKI

## 説明
自前のルート証明書、中間証明書、リーフ証明書(サーバー証明書)から成る証明書チェーンを作成します。
それらの証明書は、サーバー(nginx)とクライアントの通信に使用可能となるように、インストールされます。

tls1.2,　認証アルゴリズムはRSAの最小構成となっています。

## ファイル構成
<pre>
Project
├── Makefile
├── README.md
├── compose
│   ├── client
│   │   └── Dockerfile
│   └── server
│       ├── Dockerfile
│       └── nginx.conf
└── docker-compose.yml
</pre>

## 動作環境
 - docker
 - docker-compose
 - openssl

## 実行方法　（証明書チェーンの作成〜検証）
```
make all
```

## 有効な暗号スイート確認
```bash
make list_ciphers
```

## 削除
```bash
make clean
```