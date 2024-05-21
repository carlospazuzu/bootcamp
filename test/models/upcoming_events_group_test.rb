# frozen_string_literal: true

require 'test_helper'

class UpcomingEventsGroupTest < ActiveSupport::TestCase
  setup do
    today_date = Time.zone.today
    original_events = [Event, RegularEvent].map { |m| m.public_send(:gather_events_scheduled_on, today_date) }
    @upcoming_events = original_events.map { |e| UpcomingEvent.new(e) }
  end

  test '#build' do
    date_key = :today
    date = Time.zone.today
    assert_equal UpcomingEventsGroup.new(date_key, date, @upcoming_events), UpcomingEventsGroup.build(date_key)
  end
end
