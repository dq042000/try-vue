## 腳本安裝

### 第一次安裝使用以下指令

```bash
$ sh setup.sh
```

### 如果已經安裝過，且 DB 都已經有裝好了，單純要啟動容器及服務，使用以下指令

```bash
$ sh setup.sh -nodb
```

## 手動安裝

### docker 設定檔

```
cp docker-compose-sample.yml docker-compose.yml
```

### 啟動 docker

```
docker-compose up -d --build
```

### 安裝 vue library

```
docker exec -ti my-project-03_vite_1 yarn
```

### 執行 vue

```
docker exec -ti my-project-03_vite_1 yarn dev
```

### 網站

```
http://localhost:3000/
```