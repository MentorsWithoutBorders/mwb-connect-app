import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';

class MentorPartnershipResult {
  MentorPartnershipRequestModel? mentorPartnershipRequest;
  MentorWaitingRequest? mentorWaitingRequest;

  MentorPartnershipResult({this.mentorPartnershipRequest, this.mentorWaitingRequest});
}