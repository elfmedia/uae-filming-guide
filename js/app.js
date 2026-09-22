/**
 * UAE Commercial Filming & Drone Readiness Interactive Assessment
 * elf media Regulatory Node Engine
 */

document.addEventListener('DOMContentLoaded', () => {
  const locationSelect = document.getElementById('audit-location');
  const droneSelect = document.getElementById('audit-drone');
  const typeSelect = document.getElementById('audit-type');
  const crewSelect = document.getElementById('audit-crew');

  const riskBadge = document.getElementById('audit-risk-badge');
  const summaryBox = document.getElementById('audit-summary-text');
  const leadTimeSpan = document.getElementById('audit-lead-time');

  function calculateAssessment() {
    const loc = locationSelect ? locationSelect.value : 'abudhabi';
    const drone = droneSelect ? droneSelect.value : 'yes';
    const type = typeSelect ? typeSelect.value : 'public';
    const crew = crewSelect ? crewSelect.value : 'foreign';

    let riskLevel = 'Moderate';
    let riskColorClass = 'bg-amber-500/20 text-amber-400 border border-amber-500/30';
    let leadTime = '4 to 6 Working Days';
    let bullets = [];

    // Location analysis
    if (loc === 'abudhabi') {
      bullets.push('<strong>Abu Dhabi Film Commission (ADFC):</strong> Eligible for up to 30%-35% cash rebate on qualified production expenditure (min spend $25,000 for commercials). elf media provides certified local expenditure accounting.');
    } else if (loc === 'dubai') {
      bullets.push('<strong>Dubai Film and TV Commission (DFTC):</strong> Single-window application required. Public spaces and landmarks require municipal/RTA safety clearances.');
    } else if (loc === 'both') {
      bullets.push('<strong>Multi-Emirate Coordination:</strong> Dual filings required across ADFC and DFTC. Dual police jurisdiction NOCs needed for road transport of camera convoys.');
    } else {
      bullets.push('<strong>Northern Emirates:</strong> Sponsoring emirate media council permit required; GCAA federal flight authorization governs airspace.');
    }

    // Drone analysis
    if (drone === 'yes') {
      if (loc === 'dubai') {
        bullets.push('<strong>DCAA Drone Filming Clearance:</strong> Mandatory registered commercial RPAS operator NOC, security beacon transponder, and live pilot flight plan filing via DCAA SkyGate.');
      } else {
        bullets.push('<strong>GCAA Commercial Drone NOC:</strong> Requires MoIAT UAV registration, Ministry of Defence (MOD) security vetting, and 400ft AGL ceiling adherence.');
      }
    } else {
      bullets.push('<strong>Ground Operations:</strong> Ground cinematography permits only. Standard tripod and camera track safety perimeter required.');
    }

    // Location Type analysis
    if (type === 'public') {
      bullets.push('<strong>Public Land Filming:</strong> Municipality NOC, public liability insurance policy (minimum AED 5,000,000 indemnity), and RTA traffic approvals if vehicular traffic is impacted.');
    } else if (type === 'private') {
      bullets.push('<strong>Private Property:</strong> Landowner authorization letter plus mandatory DFTC/ADFC Private Shoot Registration Notification.');
    } else {
      bullets.push('<strong>Mixed Shoots:</strong> Comprehensive schedule segmentation required between private studio shooting and public exterior sequences.');
    }

    // Crew analysis
    if (crew === 'foreign') {
      bullets.push('<strong>International Crew Logistics:</strong> ATA Carnet required for duty-free equipment transit through AUH/DXB customs. Foreign crew require temporary media project visas via elf media Line Producer sponsorship.');
    } else if (crew === 'hybrid') {
      bullets.push('<strong>Hybrid Crew:</strong> Local Line Producer (elf media) covers liability, local crew contracts, and ICV procurement credits.');
    } else {
      bullets.push('<strong>Local UAE Crew:</strong> Expedited workflow; crew already possess local freelance media accreditations and residency.');
    }

    // Lead time & risk computation
    if (drone === 'yes' && crew === 'foreign') {
      riskLevel = 'High Regulatory Complexity';
      riskColorClass = 'bg-red-500/20 text-red-400 border border-red-500/30';
      leadTime = '7 to 10 Working Days';
    } else if (drone === 'no' && type === 'private' && crew === 'local') {
      riskLevel = 'Fast-Track Clearance';
      riskColorClass = 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30';
      leadTime = '2 to 3 Working Days';
    } else {
      riskLevel = 'Standard Commercial Clearance';
      riskColorClass = 'bg-amber-500/20 text-amber-400 border border-amber-500/30';
      leadTime = '4 to 6 Working Days';
    }

    // Render output
    if (riskBadge) {
      riskBadge.className = `px-2.5 py-1 text-xs font-bold rounded ${riskColorClass}`;
      riskBadge.textContent = riskLevel;
    }

    if (leadTimeSpan) {
      leadTimeSpan.textContent = leadTime;
    }

    if (summaryBox) {
      summaryBox.innerHTML = `
        <ul class="space-y-2">
          ${bullets.map(b => `<li class="flex items-start gap-2"><span class="text-red-400 font-bold">•</span><span>${b}</span></li>`).join('')}
        </ul>
      `;
    }
  }

  // Bind change listeners
  [locationSelect, droneSelect, typeSelect, crewSelect].forEach(el => {
    if (el) {
      el.addEventListener('change', calculateAssessment);
    }
  });

  // Initial calculation
  calculateAssessment();
});
