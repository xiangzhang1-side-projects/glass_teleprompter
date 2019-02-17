## bytes, base64, hex, uint

A 128-bit binary number is called a 128-bit UUID:
```python
a = uuid.uuid1()
```

Define its (1:1) byte representation as:
```python
>>> a.bytes
>>> '\xe6\xb7\xadf1\\\x11\xe9\xa8\x94\x18e\x90\xcf\xa2\x1b'
```
Note that it is not printable.

Define its base16 (hexademical) representation, a.k.a. standard representation, as:
```python
>>> a.hex
>>> 'e6b7ad66-315c-11e9-a894-186590cfa21b'
```
Note that dashes are only for visual clarify.

Define its unsigned-int (uint128) representation as:
```python
>>> a.int
>>> 306676146309052603664961875237988704795L
```

Define its base64 representation as:
```python
>>> base64.urlsafe_b64encode(a.bytes)
>>> 5retZjFcEemolBhlkM-iGw==
```

# 32-bit UUID

Define a 32-bit UUID as follows:

The 32-bit UUID’s hex text replaces the x's in the following:

xxxxxxxx-0000-1000-8000-00805F9B34FB

Note that 