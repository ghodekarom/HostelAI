import 'complaint_model.dart';

class RelatedCaseCandidateModel {
  final ComplaintModel complaint;
  final double similarityScore;
  final String? relationshipType; // LINKED, DUPLICATE, SEPARATE, IGNORED

  RelatedCaseCandidateModel({
    required this.complaint,
    this.similarityScore = 0.85,
    this.relationshipType,
  });

  factory RelatedCaseCandidateModel.fromComplaint(ComplaintModel complaint, {double score = 0.85}) {
    return RelatedCaseCandidateModel(
      complaint: complaint,
      similarityScore: score,
    );
  }
}
