# encoding: UTF-8

module Wice::JsAdaptor  #:nodoc:
  def self.init  #:nodoc:
    if Wice::Defaults::JS_FRAMEWORK == :prototype
      include Wice::JsAdaptor::Prototype
    else
      include Wice::JsAdaptor::Jquery
    end
  end
end