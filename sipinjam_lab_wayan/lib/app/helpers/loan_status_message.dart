const Map<String, String> _loanStatusMessages = {
  'approved': 'Peminjaman Anda telah disetujui.',
  'rejected': 'Peminjaman Anda ditolak.',
  'returned': 'Pengembalian alat telah dikonfirmasi.',
};

/// Returns a student-facing message for a loan status change, or null if the
/// status isn't one that warrants a notification (e.g. still "pending").
String? loanStatusChangeMessage(String? status) => _loanStatusMessages[status];
