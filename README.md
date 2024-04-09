1. Pruebas contra la API:

```bash
curl -XPOST http://${ipLoadBalancer}/music/post?name=oasis
curl -XGET http://${ipLoadBalancer}/music/get
```

