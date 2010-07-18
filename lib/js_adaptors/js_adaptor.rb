# encoding: UTF-8

module Wice::JsAdaptor  #:nodoc:
  def self.init  #:nodoc:
    if Wice::Defaults::JS_FRAMEWORK == :prototype
      require 'js_adaptors/prototype_adaptor.rb'
    else
      require 'js_adaptors/jquery_adaptor.rb'
    end
  end
end