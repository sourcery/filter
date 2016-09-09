require 'spec_helper'

RSpec.describe Filter::ApplyFilter do
  describe '#initialize' do
    let(:relation) { Widget }

    subject { described_class.new('produced_before', '12/01/2016', relation) }

    it 'sets up filter_name and filter_value' do
      expect(subject.filter_name).to eq :produced_before
      expect(subject.filter_value).to eq '12/01/2016'
    end

    context 'when the third argument is the model class itself' do
      it 'stores the model class in @model_class' do
        expect(subject.model_class).to eq Widget
      end
    end

    context 'when the third argument is a relation' do
      let(:relation) { Widget.where(held: false) }

      it 'stores the model class in @model_class' do
        expect(subject.model_class).to eq Widget
      end
    end
  end

  describe '#perform' do
    let(:relation) { Widget.where(held: true) }

    context 'when the scope takes an argument' do
      subject { described_class.new(:produced_before, '12/01/2016', relation) }

      it 'passes the argument along' do
        allow(relation).to receive(:produced_before).and_return('new relation')

        new_relation = subject.perform
        expect(new_relation).to eq 'new relation'

        expect(relation).to have_received(:produced_before).with('12/01/2016')
      end
    end

    context 'when the scope takes no arguments, and filter_value is truthy' do
      shared_examples_for 'calls the filter method' do |filter_value|
        subject { described_class.new(:not_delivered, filter_value, relation) }

        it 'calls the method' do
          allow(relation).to receive(:not_delivered).and_return('new relation')

          new_relation = subject.perform
          expect(new_relation).to eq 'new relation'

          expect(relation).to have_received(:not_delivered)
        end
      end

      shared_examples_for 'does not call the filter method' do |filter_value|
        subject { described_class.new(:not_delivered, filter_value, relation) }

        it 'does not calls the method' do
          allow(relation).to receive(:not_delivered).and_return('new relation')

          new_relation = subject.perform
          expect(new_relation).to eq relation

          expect(relation).to_not have_received(:not_delivered)
        end
      end

      it_should_behave_like 'calls the filter method', true
      it_should_behave_like 'calls the filter method', '1'
      it_should_behave_like 'calls the filter method', 'true'
      it_should_behave_like 'does not call the filter method', 'false'
      it_should_behave_like 'does not call the filter method', false
      it_should_behave_like 'does not call the filter method', '0'
    end

    context 'when the scope takes no arguments, and filter_value is false' do
      shared_examples_for 'does not call the filter method' do |filter_value|
        subject { described_class.new(:not_delivered, filter_value, relation) }

        it 'does not call the method' do
          allow(relation).to receive(:not_delivered)

          new_relation = subject.perform

          expect(new_relation).to eq relation
          expect(relation).to_not have_received(:not_delivered)
        end
      end

      it_should_behave_like 'does not call the filter method', false
      it_should_behave_like 'does not call the filter method', nil
      it_should_behave_like 'does not call the filter method', '0'
      it_should_behave_like 'does not call the filter method', 'false'
    end

    context 'when the scope does not exist' do
      before { allow(relation).to receive(:where).and_return('new relation') }
      subject { described_class.new(:factory_id, '9', relation) }

      it 'calls where' do
        expect(subject.perform).to eq 'new relation'
        expect(relation).to have_received(:where).with(factory_id: '9')
      end
    end

    context 'when the scope does not exist' do
      subject { described_class.new(:nonexistent_scope, true, relation) }

      it 'blows up' do
        expect{subject.perform}.to raise_exception Filter::ApplyFilter::NoFilterError, 'Widget neither responds to nor has a column named `nonexistent_scope`.'
      end
    end
  end
end
