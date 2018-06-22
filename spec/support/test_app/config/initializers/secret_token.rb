# encoding: utf-8
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if Examples::TestApp.config.respond_to?(:secret_key_base)
  Examples::TestApp.config.secret_key_base = '41aebe1604463465ca9a3d0c79244d48b668ca1db17b75fba958b31d250d42f2771eecac77be54fe2c6a919a4c40de4e5348857b77c4593987fcb890fcce8827'
else
  Examples::TestApp.config.secret_token = '41aebe1604463465ca9a3d0c79244d48b668ca1db17b75fba958b31d250d42f2771eecac77be54fe2c6a919a4c40de4e5348857b77c4593987fcb890fcce8827'
end
