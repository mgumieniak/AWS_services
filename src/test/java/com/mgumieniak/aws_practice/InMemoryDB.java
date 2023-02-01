package com.mgumieniak.aws_practice;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class InMemoryDB<K, T> {

    private final Map<K, T> db = new HashMap<>();

    public void save(K key, T value) {
        db.put(key, value);
    }

    public T getBy(K key) {
        return db.get(key);
    }

    public void deleteAll() {
        db.clear();
    }

    public Collection<T> findAll(){
        return db.values();
    }
}
