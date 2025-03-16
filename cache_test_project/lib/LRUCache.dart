class LRUCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = {};
  final List<K> _order = [];

  LRUCache(this.maxSize);
  // Adiciona ou atualiza um item no cache
  void put(K key, V value) {
    if (_cache.length >= maxSize) {
      _removeLeastRecentlyUsed();
    }
    _cache[key] = value;
    _order.add(key);
  }

  // Obtém um item do cache
  V? get(K key) {
    if (_cache.containsKey(key)) {
      _order.remove(key);
      _order.add(key);
      return _cache[key];
    }
    return null;
  }

  // Remove o item menos recentemente usado
  void _removeLeastRecentlyUsed() {
    final leastUsedKey = _order.removeAt(0);
    _cache.remove(leastUsedKey);
  }
}
