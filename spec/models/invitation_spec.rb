# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invitation do
  describe 'callbacks' do
    describe 'after_save' do
      context 'with valid data' do
        it 'invites the user' do
          team_owner = build_owner
          inviting_team = create_team(team_owner)
          update_team_with_owner(inviting_team, team_owner)
          user_to_be_invited = build_user
          valid_invitation = inviting_user_to_team(inviting_team, user_to_be_invited)
          valid_invitation.save
          expect(user_to_be_invited).to be_invited
        end
      end

      context 'with invalid data' do
        it 'does not save the invitation' do
          team_owner = build_owner
          inviting_team = create_team(team_owner)
          user_to_be_invited = build_user
          update_team_with_owner(inviting_team, team_owner)
          invitation_not_valid = inviting_user_to_team(inviting_team, user_to_be_invited)
          invalid_invitation(invitation_not_valid)
          expect(invitation_not_valid).not_to be_valid
          expect(invitation_not_valid).to be_new_record
        end

        it 'does not mark the user as invited' do
          team_owner = build_owner
          inviting_team = create_team(team_owner)
          user_to_be_not_invited = build_user
          update_team_with_owner(inviting_team, team_owner)
          invitation_not_valid = inviting_user_to_team(inviting_team, user_to_be_not_invited)
          invalid_invitation(invitation_not_valid)
          expect(user_to_be_not_invited).not_to be_invited
        end
      end
    end
  end

  describe '#event_log_statement' do
    context 'when the record is saved' do
      it 'include the name of the team' do
        team_owner = build_owner
        inviting_team = create_team(team_owner)
        user_to_be_invited = build_user
        update_team_with_owner(inviting_team, team_owner)
        valid_invitation = inviting_user_to_team(inviting_team, user_to_be_invited)
        valid_invitation.save
        log_statement = valid_invitation.event_log_statement
        expect(log_statement).to include('A fine team')
      end

      it 'include the email of the invitee' do
        team_owner = build_owner
        inviting_team = create_team(team_owner)
        user_to_be_invited = build_user
        update_team_with_owner(inviting_team, team_owner)
        valid_invitation = inviting_user_to_team(inviting_team, user_to_be_invited)
        valid_invitation.save
        log_statement = valid_invitation.event_log_statement
        expect(log_statement).to include('rookie@example.com')
      end
    end

    context 'when the record is not saved but valid' do
      it 'includes the name of the team' do
        team_owner = build_owner
        inviting_team = create_team(team_owner)
        user_to_be_invited = build_user
        update_team_with_owner(inviting_team, team_owner)
        valid_invitation = inviting_user_to_team(inviting_team, user_to_be_invited)
        log_statement = valid_invitation.event_log_statement
        expect(log_statement).to include('A fine team')
      end

      it 'includes the email of the invitee' do
        team_owner = build_owner
        inviting_team = create_team(team_owner)
        user_to_be_invited = build_user
        update_team_with_owner(inviting_team, team_owner)
        valid_invitation = inviting_user_to_team(inviting_team, user_to_be_invited)
        log_statement = valid_invitation.event_log_statement
        expect(log_statement).to include('rookie@example.com')
      end

      it "includes the word 'PENDING'" do
        team_owner = build_owner
        inviting_team = create_team(team_owner)
        user_to_be_invited = build_user
        update_team_with_owner(inviting_team, team_owner)
        valid_invitation = inviting_user_to_team(inviting_team, user_to_be_invited)
        log_statement = valid_invitation.event_log_statement
        expect(log_statement).to include('PENDING')
      end
    end

    context 'when the record is not saved and not valid' do
      it 'includes INVALID' do
        team_owner = build_owner
        inviting_team = create_team(team_owner)
        user_to_be_invited = build_user
        update_team_with_owner(inviting_team, team_owner)
        invalid_invitation = inviting_user_to_team(inviting_team, user_to_be_invited)
        invalid_invitation.user = nil
        log_statement = invalid_invitation.event_log_statement
        expect(log_statement).to include('INVALID')
      end
    end
  end

  def invalid_invitation(invitation)
    invitation.team = nil
    invitation.save
  end

  def build_user
    User.new(email: 'rookie@example.com')
  end

  def build_owner
    User.new
  end

  def create_team(owner)
    Team.new(name: 'A fine team', owner: owner)
  end

  def update_team_with_owner(team, owner)
    owner.update!(team: team)
  end

  def inviting_user_to_team(team, user)
    Invitation.new(team: team, user: user)
  end
end
