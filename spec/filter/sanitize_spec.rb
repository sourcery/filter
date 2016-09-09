require 'spec_helper'
require 'action_controller'

RSpec.describe Filter::Sanitize do
  subject { described_class.new }

  let(:attributes) do
    ActionController::Parameters.new(
      delivered_before: '01/01/2016',
      delivered_after: '',
      held: 'true',
      due_after: 'shoot'
    )
  end

  let(:permitted_attributes) { attributes.permit(:delivered_before, :delivered_after, :held) }

  it 'blows up if parameters are not permitted' do
    expect{subject.sanitize(attributes)}.to raise_exception ActiveModel::ForbiddenAttributesError
  end

  it 'does not blow up if parameters are permitted' do
    expect{subject.sanitize(permitted_attributes)}.to_not raise_error
  end

  it 'sanitized params' do
    sanitized_attributes = subject.sanitize(permitted_attributes)

    expect(sanitized_attributes).to match(
      'delivered_before' => '01/01/2016',
      'delivered_after' => '',
      'held' => 'true'
    )
  end
end
