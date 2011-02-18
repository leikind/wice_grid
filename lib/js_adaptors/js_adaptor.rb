# encoding: UTF-8

module Wice::JsAdaptor  #:nodoc:
  mattr_accessor :calendar_module
  def self.init  #:nodoc:
    if Wice::ConfigurationProvider.value_for(:JS_FRAMEWORK) == :prototype
      include Wice::JsAdaptor::Prototype
    else
      include Wice::JsAdaptor::Jquery
    end
  end
end