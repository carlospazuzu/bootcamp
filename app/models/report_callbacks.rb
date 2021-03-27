# frozen_string_literal: true

class ReportCallbacks
  def after_save(report)
    return unless report.saved_changes?

    Cache.delete_unchecked_report_count

    return unless report.first_public?

    report.update!(published_at: report.updated_at)
    notify_users(report)
  end

  def after_create(report)
    create_author_watch(report)

    send_first_report_notification(report) if report.first? && report.first_public?
  end

  def after_update(report)
    send_first_report_notification(report) if report.first? && report.first_public?
  end

  def after_destroy(report)
    Cache.delete_unchecked_report_count
    delete_notification(report)
  end

  private

  def create_author_watch(report)
    Watch.create!(user: report.user, watchable: report)
  end

  def send_first_report_notification(report)
    receiver_list = User.where(retired_on: nil)
    receiver_list.each do |receiver|
      NotificationFacade.first_report(report, receiver) if report.sender != receiver
    end
  end

  def notify_users(report)
    notify_advisers(report) if report.user.trainee? && report.user.company_id?
    notify_followers(report)
    report.notify_all_mention_user
  end

  def notify_advisers(report)
    report.user.company.advisers.each do |adviser|
      NotificationFacade.trainee_report(report, adviser)
      create_advisers_watch(report, adviser)
    end
  end

  def notify_followers(report)
    report.user.followers.each do |follower|
      NotificationFacade.following_report(report, follower)
      create_following_watch(report, follower)
    end
  end

  def create_advisers_watch(report, adviser)
    Watch.create!(user: adviser, watchable: report)
  end

  def create_following_watch(report, follower)
    Watch.create!(user: follower, watchable: report)
  end

  def delete_notification(report)
    Notification.where(path: "/reports/#{report.id}").destroy_all
  end
end
