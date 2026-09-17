package com.hfcms.ai.client;

import com.hfcms.ai.dto.ComplaintAnalysisResult;
import com.hfcms.complaints.entity.Complaint;

public interface AiClient {
    ComplaintAnalysisResult analyzeComplaint(Complaint complaint);
    String getModelName();
}
