#
# This is free and unencumbered software released into the public domain.
# 
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
# 
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# For more information, please refer to <http://unlicense.org/>
#

# This was quickly written as a proof of concept for passing decryptable
# passwords. Before I hear about it, I know passwords should never be
# decryptable and the design should truly be changed. That being said,
# this couldn't be helped in my application. For traditional password
# storage for authentication purposes, I would suggest looking into
# bcrypt, SHA-256, SHA-512, and password salts.

require 'openssl'

### Generate the RSA key pair

puts 'Generating a random key...'
rsa_key = OpenSSL::PKey::RSA.new(2048)

des3_cipher =  OpenSSL::Cipher::Cipher.new('des3')

puts 'Enter a password to encrypt the private key:'
private_key_password = gets.chomp

puts 'Encrypting the private key...'
private_key_pem = rsa_key.to_pem(des3_cipher, private_key_password)
public_key_pem = rsa_key.public_key.to_pem
# key_pair_pem = private_key_pem + public_key_pem

puts 'Encrypted private key PEM:'
puts private_key_pem

puts 'Public key PEM:'
puts public_key_pem

### Encrypt the data with the public key

# To encrypt data with the public key we only need the public key PEM string.
# The private key and password are only needed on the decryption side.

puts 'Enter a string to encrypt:'
string_to_encrypt = gets.chomp

puts 'Trying to encrypt input string with the public key...'
rsa_public_key = OpenSSL::PKey::RSA.new(public_key_pem)

encrypted_string = rsa_public_key.public_key.public_encrypt(string_to_encrypt)

puts '"inspected" encrypted string:'
puts encrypted_string.inspect
puts "Encrypted string length: #{encrypted_string.length}"

### Decrypt the data using the private key

# Here we need the encrypted string, private PEM string, and the private
# key password. Note that the private key PEM describes the des3 encryption
# cipher so we don't need the Cipher object any more.

puts 'Loading the private key...'

rsa_private_key = OpenSSL::PKey::RSA.new(private_key_pem, private_key_password)
decrypted_string = rsa_private_key.private_decrypt(encrypted_string)

puts '"inspected" decrypted string:'
puts decrypted_string.inspect

