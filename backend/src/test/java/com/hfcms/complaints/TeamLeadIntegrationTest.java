package com.hfcms.complaints;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hfcms.auth.security.JwtTokenProvider;
import com.hfcms.auth.security.UserPrincipal;
import com.hfcms.categories.entity.Category;
import com.hfcms.categories.repository.CategoryRepository;
import com.hfcms.complaints.dto.InterventionRequest;
import com.hfcms.complaints.entity.Complaint;
import com.hfcms.complaints.entity.ComplaintStatus;
import com.hfcms.complaints.entity.Priority;
import com.hfcms.complaints.entity.Severity;
import com.hfcms.complaints.repository.ComplaintRepository;
import com.hfcms.hostels.entity.Block;
import com.hfcms.hostels.entity.Hostel;
import com.hfcms.hostels.repository.BlockRepository;
import com.hfcms.hostels.repository.HostelRepository;
import com.hfcms.teams.entity.Team;
import com.hfcms.teams.entity.Technician;
import com.hfcms.teams.repository.TeamRepository;
import com.hfcms.teams.repository.TechnicianRepository;
import com.hfcms.users.entity.Role;
import com.hfcms.users.entity.User;
import com.hfcms.users.entity.UserStatus;
import com.hfcms.users.repository.RoleRepository;
import com.hfcms.users.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Duration;
import java.time.Instant;
import java.util.Collections;
import java.util.UUID;

import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class TeamLeadIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private TechnicianRepository technicianRepository;

    @Autowired
    private HostelRepository hostelRepository;

    @Autowired
    private BlockRepository blockRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ComplaintRepository complaintRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User teamLeadUser;
    private String teamLeadToken;
    private String studentToken;
    private Complaint testComplaint;
    private Technician alternateTech;

    @BeforeEach
    void setUp() {
        Role leadRole = roleRepository.findByName("ROLE_TEAM_LEAD")
                .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_TEAM_LEAD").description("Team Lead").build()));
        Role studentRole = roleRepository.findByName("ROLE_STUDENT")
                .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_STUDENT").description("Student").build()));
        Role techRole = roleRepository.findByName("ROLE_TECHNICIAN")
                .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_TECHNICIAN").description("Technician").build()));

        String uid = UUID.randomUUID().toString().substring(0, 8);
        teamLeadUser = userRepository.save(User.builder()
                .email("lead-" + uid + "@hostel.edu")
                .fullName("Team Lead Verma")
                .passwordHash("hashed")
                .role(leadRole)
                .status(UserStatus.ACTIVE)
                .build());

        User studentUser = userRepository.save(User.builder()
                .email("student-" + uid + "@hostel.edu")
                .fullName("Student Rahul")
                .passwordHash("hashed")
                .role(studentRole)
                .status(UserStatus.ACTIVE)
                .build());

        User techUser = userRepository.save(User.builder()
                .email("tech-" + uid + "@hostel.edu")
                .fullName("Tech Mohan")
                .passwordHash("hashed")
                .role(techRole)
                .status(UserStatus.ACTIVE)
                .build());

        UserPrincipal leadPrincipal = UserPrincipal.builder()
                .id(teamLeadUser.getId())
                .email(teamLeadUser.getEmail())
                .fullName(teamLeadUser.getFullName())
                .roleName("ROLE_TEAM_LEAD")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_TEAM_LEAD")))
                .build();
        teamLeadToken = jwtTokenProvider.generateAccessToken(leadPrincipal);

        UserPrincipal studentPrincipal = UserPrincipal.builder()
                .id(studentUser.getId())
                .email(studentUser.getEmail())
                .fullName(studentUser.getFullName())
                .roleName("ROLE_STUDENT")
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_STUDENT")))
                .build();
        studentToken = jwtTokenProvider.generateAccessToken(studentPrincipal);

        Team electricalTeam = teamRepository.findAll().stream().findFirst()
                .orElseGet(() -> teamRepository.save(Team.builder()
                        .name("Electrical Team " + uid)
                        .code("ELEC_" + uid)
                        .description("Electrical")
                        .build()));

        alternateTech = technicianRepository.save(Technician.builder()
                .user(techUser)
                .team(electricalTeam)
                .isAvailable(true)
                .activeTasksCount(0)
                .build());

        Hostel hostel = hostelRepository.findAll().stream().findFirst()
                .orElseGet(() -> hostelRepository.save(Hostel.builder().name("Hostel Alpha").code("H-A-" + uid).build()));
        Block block = blockRepository.findAll().stream().findFirst()
                .orElseGet(() -> blockRepository.save(Block.builder().hostel(hostel).name("Block 1").code("B1-" + uid).build()));
        Category category = categoryRepository.findAll().stream().findFirst()
                .orElseGet(() -> categoryRepository.save(Category.builder().name("Electrical").code("CAT_ELEC_" + uid).slaHoursP3(24).build()));

        testComplaint = complaintRepository.save(Complaint.builder()
                .caseNumber("HFCMS-2026-TL-" + uid)
                .student(studentUser)
                .hostel(hostel)
                .block(block)
                .category(category)
                .description("Electrical short circuit sparking in corridor")
                .status(ComplaintStatus.AT_RISK)
                .severity(Severity.CRITICAL)
                .priority(Priority.P1)
                .isAtRisk(true)
                .assignedTeam(electricalTeam)
                .slaDeadline(Instant.now().minus(Duration.ofHours(1)))
                .build());
    }

    @Test
    void student_accessingTeamLeadAtRiskQueue_isForbidden() throws Exception {
        mockMvc.perform(get("/api/v1/team-lead/at-risk")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isForbidden());
    }

    @Test
    void teamLead_canGetAtRiskQueue() throws Exception {
        mockMvc.perform(get("/api/v1/team-lead/at-risk")
                        .header("Authorization", "Bearer " + teamLeadToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.content[0].caseNumber", is(testComplaint.getCaseNumber())));
    }

    @Test
    void teamLead_canGetCaseContext() throws Exception {
        mockMvc.perform(get("/api/v1/complaints/" + testComplaint.getId() + "/context")
                        .header("Authorization", "Bearer " + teamLeadToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.caseNumber", is(testComplaint.getCaseNumber())))
                .andExpect(jsonPath("$.data.isSlaBreached", is(true)));
    }

    @Test
    void teamLead_canApplyIntervention() throws Exception {
        InterventionRequest request = InterventionRequest.builder()
                .actionType(InterventionRequest.ActionType.REASSIGN_TECHNICIAN)
                .newTechnicianId(alternateTech.getId())
                .reason("Escalated emergency: reassigned to senior electrical technician")
                .build();

        mockMvc.perform(post("/api/v1/complaints/" + testComplaint.getId() + "/intervene")
                        .header("Authorization", "Bearer " + teamLeadToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)))
                .andExpect(jsonPath("$.data.status", is("ACTIVE")))
                .andExpect(jsonPath("$.data.assignedTechnicianId", is(alternateTech.getId().intValue())));
    }
}
