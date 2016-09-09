require 'spec_helper'

describe Filter::Base do
  let(:filter_class) do
    Class.new(described_class)
  end

  let(:attributes) { { my: :attributes, deep: { nested: :attributes }, empty: '', none: nil } }
  subject { filter_class.new(attributes: attributes, relation: 'Record') }

  describe '#initialize' do
    it 'sets up the ostruct, performs filtering and assigns @original_relation' do
      expect_any_instance_of(described_class).to receive(:setup_ostruct).with(attributes)
      expect_any_instance_of(described_class).to receive(:perform_filtering)
      expect(subject.original_relation).to eq 'Record'
    end
  end

  describe '#setup_ostruct' do
    let(:sanitize) { double(sanitize: { sanitized: :attributes }) }

    before do
      filter_class::DEFAULTS = {
        default: :value,
        sanitized: :booger
      }
    end

    it 'sets the delegation target to an ostruct initialized using defaults and sanitized attributes' do
      allow_any_instance_of(described_class).to receive(:perform_filtering)
      allow(Filter::Sanitize).to receive(:new).and_return(sanitize)
      subject
      expect(subject.sanitized).to eq :attributes
      expect(subject.default).to eq :value
    end
  end

  describe '#count' do
    let(:relation) { double(count: 1) }
    subject { Filter::Base.new(relation: relation) }
    it 'returns the count of the relation' do
      expect(subject.count).to eq 1
    end
  end

  describe '#next/#previous' do
    subject { Filter::Base.new(relation: Widget, attributes: { has_defect: true }) }

    specify do
      widgets = 5.times.map do |i|
        Widget.create!(
          has_defect: ((i % 2) == 0),
          sku: "SKU #{i}"
        )
      end

      expect(subject.next(widgets[2]).sku).to eq widgets[4].sku
      expect(subject.next(widgets[4]).sku).to eq widgets[0].sku
      expect(subject.next(widgets[0]).sku).to eq widgets[2].sku

      expect(subject.previous(widgets[2]).sku).to eq widgets[0].sku
      expect(subject.previous(widgets[4]).sku).to eq widgets[2].sku
      expect(subject.previous(widgets[0]).sku).to eq widgets[4].sku
    end
  end

  describe '.to_query' do
    subject { Filter::Base.new(relation: Widget, attributes: { id: 1 }) }

    it 'turns the attributes to query params' do
      expect(subject.to_query).to eq "filter_base%5Bid%5D=1"
      expect(subject.to_url).to eq "?filter_base%5Bid%5D=1"
    end
  end

  describe '#perform_filtering' do
    let(:apply_filter) { double }

    it 'applies filters' do
      allow(apply_filter).to receive(:perform).and_return('filtered from :my')
      allow(Filter::ApplyFilter).to receive(:new).and_return(apply_filter)
      subject
      expect(Filter::ApplyFilter).to have_received(:new).with(:my, :attributes, 'Record')
      expect(Filter::ApplyFilter).to have_received(:new).with(:deep, { nested: :attributes }, 'filtered from :my')
      expect(Filter::ApplyFilter).to_not have_received(:new).with(:empty, '', anything)
      expect(Filter::ApplyFilter).to_not have_received(:new).with(:none, nil, anything)
      expect(subject.relation).to eq 'filtered from :my'
    end
  end

  describe '#fork' do
    before do
      # allow_any_instance_of(described_class).to receive(:setup_ostruct).with(attributes)
      allow_any_instance_of(described_class).to receive(:perform_filtering)
      # allow_any_instance_of(described_class).to receive(:to_h).and_return(attributes)
      allow(subject).to receive(:relation).and_return('newer relation')
      allow(filter_class).to receive(:new).and_return('forked')
    end

    it 'initializes a new filter' do
      forked = subject.fork
      expect(forked).to eq 'forked'
      expect(filter_class).to have_received(:new).with(
        attributes: {
          my: :attributes,
          deep: { nested: :attributes },
          empty: '',
          none: nil
        },
        relation: 'Record'
      )
    end

    it 'can skip one attribute' do
      forked = subject.fork(skip: :deep)
      expect(forked).to eq 'forked'
      expect(filter_class).to have_received(:new).with(
        attributes: {
          my: :attributes,
          empty: '',
          none: nil
        },
        relation: 'Record'
      )
    end

    it 'can skip multiple attributes' do
      forked = subject.fork(skip: [:deep, :none])
      expect(forked).to eq 'forked'
      expect(filter_class).to have_received(:new).with(
        attributes: {
          my: :attributes,
          empty: ''
        },
        relation: 'Record'
      )
    end

    it 'can override/add attributes' do
      forked = subject.fork(attributes: { deep: 'new deep', new_filter: 'madcap'})
      expect(forked).to eq 'forked'
      expect(filter_class).to have_received(:new).with(
        attributes: {
          my: :attributes,
          deep: 'new deep',
          new_filter: 'madcap',
          empty: '',
          none: nil
        },
        relation: 'Record'
      )
    end
  end
end
