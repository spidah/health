require 'abstract_unit'
require 'controller/fake_models'

uses_mocha 'TestTemplateRecompilation' do
  class CompiledTemplatesTest < Test::Unit::TestCase
    def setup
      @view = ActionView::Base.new(ActionController::Base.view_paths, {})
      @compiled_templates = ActionView::Base::CompiledTemplates
      @compiled_templates.instance_methods.each do |m|
        @compiled_templates.send(:remove_method, m) if m =~ /^_run_/
      end
    end

    def test_template_gets_compiled
      assert_equal 0, @compiled_templates.instance_methods.size
      assert_equal "Hello world!", @view.render("test/hello_world.erb")
      assert_equal 1, @compiled_templates.instance_methods.size
    end

    def test_template_gets_recompiled_when_using_different_keys_in_local_assigns
      assert_equal 0, @compiled_templates.instance_methods.size
      assert_equal "Hello world!", @view.render("test/hello_world.erb")
      assert_equal "Hello world!", @view.render("test/hello_world.erb", {:foo => "bar"})
      assert_equal 2, @compiled_templates.instance_methods.size
    end

    def test_compiled_template_will_not_be_recompiled_when_rendered_with_identical_local_assigns
      assert_equal 0, @compiled_templates.instance_methods.size
      assert_equal "Hello world!", @view.render("test/hello_world.erb")
      ActionView::Template.any_instance.expects(:compile!).never
      assert_equal "Hello world!", @view.render("test/hello_world.erb")
    end

    def test_compiled_template_will_always_be_recompiled_when_rendered_if_template_is_outside_cache
      assert_equal 0, @compiled_templates.instance_methods.size
      assert_equal "Hello world!", @view.render("#{FIXTURE_LOAD_PATH}/test/hello_world.erb")
      ActionView::Template.any_instance.expects(:compile!).times(3)
      3.times { assert_equal "Hello world!", @view.render("#{FIXTURE_LOAD_PATH}/test/hello_world.erb") }
    end
  end
end