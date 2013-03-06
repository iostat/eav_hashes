require 'spec_helper'

describe EavMigrationGenerator do
  let(:top_level_model_generator) { EavMigrationGenerator.new(['TestModel', 'test_hash']) }
  let(:one_module_generator) { EavMigrationGenerator.new(['Foo::TestModel', 'test_hash']) }
  let(:multi_module_generator) { EavMigrationGenerator.new(['Foo::Bar::TestModel', 'test_hash']) }

  describe "#model_association_name" do
    context "when the model is at the top level" do
      it "should underscore the model name" do
        top_level_model_generator.model_association_name.should == "test_model"
      end
    end

    context "when the model is namespaced by one module" do
      it "should underscore the model name, replacing the slash with an underscore" do
        one_module_generator.model_association_name.should == "foo_test_model"
      end
    end

    context "when the model is namespaced by multiple modules" do
      it "should underscore the model name, replacing the slashes with underscores" do
        multi_module_generator.model_association_name.should == "foo_bar_test_model"
      end
    end
  end

  describe "#table_name" do
    context "when the model is at the top level" do
      it "should underscore the model name and append the hash name" do
        top_level_model_generator.table_name.should == "test_model_test_hash"
      end
    end

    context "when the model is namespaced by one module" do
      it "should underscore the model name, replacing the slash with an underscore, and append the hash name" do
        one_module_generator.table_name.should == "foo_test_model_test_hash"
      end
    end

    context "when the model is namespaced by multiple modules" do
      it "should underscore the model name, replacing the slashes with underscores, and append the hash name" do
        multi_module_generator.table_name.should == "foo_bar_test_model_test_hash"
      end
    end
  end

  describe "#migration_file_name" do
    context "when the model is at the top level" do
      it "should return create_ followed by the table name" do
        top_level_model_generator.migration_file_name.should == "create_test_model_test_hash"
      end
    end

    context "when the model is namespaced by one or more modules" do
      it "should return create_ followed by the table name, with module names included" do
        multi_module_generator.migration_file_name.should == "create_foo_bar_test_model_test_hash"
      end
    end
  end
end