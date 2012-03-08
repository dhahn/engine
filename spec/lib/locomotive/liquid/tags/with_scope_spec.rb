require 'spec_helper'

describe Locomotive::Liquid::Tags::WithScope do

  it 'decodes basic options (boolean, integer, ...)' do
    scope = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'active:true price:42 title:\'foo\' hidden:false', ["{% endwith_scope %}"], {})
    attributes = scope.send(:decode, scope.instance_variable_get(:@attributes), ::Liquid::Context.new)
    attributes['active'].should == true
    attributes['price'].should == 42
    attributes['title'].should == 'foo'
    attributes['hidden'].should == false
  end

  it 'decodes more complex options' do
    scope = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'price.gt:42.0 price.lt:50', ["{% endwith_scope %}"], {})
    attributes = scope.send(:decode, scope.instance_variable_get(:@attributes), ::Liquid::Context.new)
    attributes['price.gt'].should == 42.0
    attributes['price.lt'].should == 50
  end

  it 'decodes context variable' do
    scope = Locomotive::Liquid::Tags::WithScope.new('with_scope', 'category: params.type', ["{% endwith_scope %}"], {})
    attributes = scope.send(:decode, scope.instance_variable_get(:@attributes), ::Liquid::Context.new({ 'params' => { 'type' => 'posts' } }))
    attributes['category'].should == 'posts'
  end

  it 'stores attributes in the context' do
    template = ::Liquid::Template.parse("{% with_scope active:true title:'foo' %}{{ with_scope.active }}-{{ with_scope.title }}{% endwith_scope %}")
    text = template.render
    text.should == "true-foo"
  end


end
