# encoding: UTF-8

module Wice::JsAdaptor  #:nodoc:
  mattr_accessor :calendar_module
  def self.init  #:nodoc:
    include Wice::JsAdaptor::Jquery
  end
end