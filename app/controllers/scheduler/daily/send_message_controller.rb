# frozen_string_literal: true

class Scheduler::Daily::SendMessageController < SchedulerController
  def show
    mark_message_as_sent_for_hibernated_student
    sent_student_followup_message
    head :ok
  end

  private

  # FIXME: 一次対応として一回でも休会している受講生にはメッセージ送信済みとする
  #        別Issueで入会n日目、休会開けn日目目の受講生にメッセージを送信する方針へ改修してほしい
  #        改修後、このメソッドは不要になると思われるので削除すること
  def mark_message_as_sent_for_hibernated_student
    User.find_each do |user|
      user.update!(sent_student_followup_message: true) if user.hibernated?
    end
  end

  def sent_student_followup_message
    @komagata = User.find_by(login_name: 'komagata')

    User.students.find_each do |student|
      next unless student.message_send_target?

      @komagata.comments.create(
        description: I18n.t('send_message.description'),
        commentable_id: Talk.find_by(user_id: student.id).id,
        commentable_type: 'Talk'
      )
      student.update!(sent_student_followup_message: true)
    end
  end
end
