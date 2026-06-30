#!/bin/bash
# Build all 4 UI changes
python3 << 'PYEOF'
fp = '/Users/aman/Documents/ggn-management-dashboard/index.html'
with open(fp, 'r', encoding='utf-8') as f:
    html = f.read()

# ===== EDIT 1: Add slideIn CSS animation =====
old_css = """        .popup-scrollbar::-webkit-scrollbar-thumb:hover {
            background: rgba(255, 255, 255, 0.5);
        }
    </style>"""
new_css = """        .popup-scrollbar::-webkit-scrollbar-thumb:hover {
            background: rgba(255, 255, 255, 0.5);
        }
        @keyframes slideIn {
            from { transform: translateX(100%); }
            to { transform: translateX(0); }
        }
    </style>"""
html = html.replace(old_css, new_css)

# ===== EDIT 2: Replace activeTab state with openPanel =====
html = html.replace(
    "const [activeTab, setActiveTab] = useState(null);",
    "const [openPanel, setOpenPanel] = useState(null);"
)
html = html.replace(
    "const [selectedDept, setSelectedDept] = useState(null);",
    "const [selectedDept, setSelectedDept] = useState(null);\n            const [panelSelectedDept, setPanelSelectedDept] = useState(null);"
)

# ===== EDIT 3: Remove hash sync effect (replace both effects) =====
old_hash = """            useEffect(() => {
                const hash = window.location.hash.replace('#', '');
                if (hash) {
                    const [tab, dept] = hash.split('/');
                    if (['sukuan','matriks','sektor','lengkap'].includes(tab)) {
                        setActiveTab(tab);
                        if (dept) setSelectedDept(dept);
                    }
                }
            }, []);

            useEffect(() => {
                const hash = activeTab ? (selectedDept ? `${activeTab}/${selectedDept}` : activeTab) : '';
                if (!hash && window.location.hash) { window.history.replaceState(null, '', window.location.pathname); } else if (window.location.hash !== `#${hash}`) {
                    window.history.replaceState(null, '', `#${hash}`);
                }
            }, [activeTab, selectedDept]);"""
new_no_hash = """            // (hash sync removed - tabs now open panels)"""
html = html.replace(old_hash, new_no_hash)

# ===== EDIT 4: Tab click handlers (header + pill bar) =====
html = html.replace(
    'onClick={() => setActiveTab(activeTab === t.id ? null : t.id)}',
    'onClick={() => setOpenPanel(t.id)}'
)

# Remove active styling from tabs (no more highlighted tab)
html = html.replace(
    "className={`text-sm font-bold text-center leading-tight transition-colors ${activeTab === t.id ? 'text-blue-700 dark:text-blue-400' : 'text-gray-600 dark:text-slate-300 hover:text-blue-700 dark:hover:text-blue-400'}`}>",
    "className={'text-sm font-bold text-center leading-tight transition-colors text-gray-600 dark:text-slate-300 hover:text-blue-700 dark:hover:text-blue-400'}>"
)

html = html.replace(
    """                                        className={`flex items-center gap-2 px-4 py-2.5 rounded-lg text-sm font-bold transition-all whitespace-nowrap ${
                                            activeTab === t.id
                                                ? 'bg-unisza-blue text-white shadow-[0_0_10px_rgba(46,77,167,0.45)]'
                                                : 'bg-gray-100 dark:bg-slate-800 text-gray-600 dark:text-slate-300 hover:bg-gray-200 dark:hover:bg-slate-700'
                                        }`}>""",
    """                                        className="flex items-center gap-2 px-4 py-2.5 rounded-lg text-sm font-bold transition-all whitespace-nowrap bg-gray-100 dark:bg-slate-800 text-gray-600 dark:text-slate-300 hover:bg-gray-200 dark:hover:bg-slate-700">"""
)

# ===== EDIT 5: Move SectionAktiviti block to after ProjectTimeline =====
# Remove the Ringkasan section from its current position (lines 1142-1200)
old_ringkasan_at_top = """                    {/* RINGKASAN AKTIVITI */}
                    {activeTab === null && (
                        <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-gray-200 dark:border-slate-700 p-5 fade-in">
                            <div className="mb-6">
                                <h2 className="text-xl font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2">
                                    <i data-lucide="bar-chart-3" className="w-5 h-5 text-blue-600"></i> Ringkasan Aktiviti
                                </h2>
                                <p className="text-sm text-gray-500 dark:text-slate-400 mt-1">
                                    Taburan aktiviti mengikut jabatan. Klik bar untuk lihat projek jabatan tersebut.
                                </p>
                            </div>

                            <div className="flex items-center gap-5 mb-5 text-xs font-semibold">
                                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-green-500"></span> Selesai</span>
                                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-blue-500"></span> Sedang Berjalan</span>
                                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-red-500"></span> Lewat</span>
                            </div>

                            <div className="space-y-5">
                                {['Pentadbiran','Akademik','Hal Ehwal Siswazah'].map(dept => {
                                    const dProjects = projects.filter(p => p.Jabatan === dept);
                                    const total = projects.length || 1;
                                    const countCompleted = dProjects.filter(p => parseInt(p.Kemajuan) === 100).length;
                                    const countOverdue = dProjects.filter(p => checkIsOverdue(p.TarikhAsal, p.Kemajuan)).length;
                                    const countOngoing = dProjects.length - countCompleted - countOverdue;
                                    const pct = Math.round((dProjects.length / total) * 100);
                                    const deptColor = dept === 'Pentadbiran' ? 'bg-blue-500' : dept === 'Akademik' ? 'bg-orange-500' : 'bg-green-500';

                                    return (
                                        <button key={dept} onClick={() => handleDeptBarClick(dept)} className="w-full text-left group cursor-pointer">
                                            <div className="flex justify-between mb-1.5">
                                                <span className="text-sm font-bold text-gray-700 dark:text-slate-200 flex items-center gap-1.5">
                                                    <i data-lucide={dept === 'Pentadbiran' ? 'home' : dept === 'Akademik' ? 'feather' : 'graduation-cap'} className="w-4 h-4 opacity-70"></i>
                                                    {dept}
                                                </span>
                                                <span className="text-xs font-bold text-gray-500 dark:text-slate-400">{dProjects.length}/{total} ({pct}%)</span>
                                            </div>
                                            <div className="relative w-full h-9 bg-gray-100 dark:bg-slate-900 rounded-lg overflow-hidden border border-gray-200 dark:border-slate-700 group-hover:ring-2 group-hover:ring-blue-300 transition-all">
                                                <div className="absolute inset-y-0 left-0 flex" style={{ width: pct + '%' }}>
                                                    {countCompleted > 0 && <div className="h-full bg-green-500 transition-all" style={{ width: (countCompleted / (dProjects.length || 1)) * 100 + '%' }}></div>}
                                                    {countOngoing > 0 && <div className={`h-full ${deptColor} transition-all`} style={{ width: (countOngoing / (dProjects.length || 1)) * 100 + '%' }}></div>}
                                                    {countOverdue > 0 && <div className="h-full bg-red-500 transition-all" style={{ width: (countOverdue / (dProjects.length || 1)) * 100 + '%' }}></div>}
                                                </div>
                                                {dProjects.length > 0 && (
                                                    <div className="absolute inset-0 flex items-center px-3 text-xs font-bold text-white drop-shadow-[0_0_4px_rgba(0,0,0,0.5)]">
                                                        {countCompleted}/{countOngoing}/{countOverdue}
                                                    </div>
                                                )}
                                            </div>
                                        </button>
                                    );
                                })}
                            </div>

                            <div className="mt-5 pt-3 border-t border-gray-200 dark:border-slate-700 text-right text-xs text-gray-500 dark:text-slate-400">
                                Jumlah keseluruhan: <span className="font-bold text-gray-700 dark:text-slate-200">{projects.length} aktiviti</span>
                            </div>
                        </div>
                    )}"""

# The ringkasan section will be re-inserted later at the bottom
# But first, let me check if the exact text matches
idx = html.find(old_ringkasan_at_top)
if idx == -1:
    print("ERROR: Ringkasan section not found at top")
    # Try to find a shorter unique fragment
    idx = html.find("Taburan aktiviti mengikut jabatan. Klik bar untuk lihat projek jabatan tersebut.")
    if idx > 0:
        print(f"  Found ringkasan text at {idx}")
else:
    print(f"  Found ringkasan section at {idx}")

# Remove ringkasan from top and save it
# We'll reconstruct it without the activeTab gate
ringkasan_html = """                    {/* RINGKASAN AKTIVITI */}
                    {projects.length > 0 && (
                        <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-gray-200 dark:border-slate-700 p-5 fade-in">
                            <div className="mb-6">
                                <h2 className="text-xl font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2">
                                    <i data-lucide="bar-chart-3" className="w-5 h-5 text-blue-600"></i> Ringkasan Aktiviti
                                </h2>
                                <p className="text-sm text-gray-500 dark:text-slate-400 mt-1">
                                    Taburan aktiviti mengikut jabatan. Klik bar untuk lihat projek jabatan tersebut.
                                </p>
                            </div>

                            <div className="flex items-center gap-5 mb-5 text-xs font-semibold">
                                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-green-500"></span> Selesai</span>
                                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-blue-500"></span> Sedang Berjalan</span>
                                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-red-500"></span> Lewat</span>
                            </div>

                            <div className="space-y-5">
                                {['Pentadbiran','Akademik','Hal Ehwal Siswazah'].map(dept => {
                                    const dProjects = projects.filter(p => p.Jabatan === dept);
                                    const total = projects.length || 1;
                                    const countCompleted = dProjects.filter(p => parseInt(p.Kemajuan) === 100).length;
                                    const countOverdue = dProjects.filter(p => checkIsOverdue(p.TarikhAsal, p.Kemajuan)).length;
                                    const countOngoing = dProjects.length - countCompleted - countOverdue;
                                    const pct = Math.round((dProjects.length / total) * 100);
                                    const deptColor = dept === 'Pentadbiran' ? 'bg-blue-500' : dept === 'Akademik' ? 'bg-orange-500' : 'bg-green-500';

                                    return (
                                        <button key={dept} onClick={() => handleDeptBarClick(dept)} className="w-full text-left group cursor-pointer">
                                            <div className="flex justify-between mb-1.5">
                                                <span className="text-sm font-bold text-gray-700 dark:text-slate-200 flex items-center gap-1.5">
                                                    <i data-lucide={dept === 'Pentadbiran' ? 'home' : dept === 'Akademik' ? 'feather' : 'graduation-cap'} className="w-4 h-4 opacity-70"></i>
                                                    {dept}
                                                </span>
                                                <span className="text-xs font-bold text-gray-500 dark:text-slate-400">{dProjects.length}/{total} ({pct}%)</span>
                                            </div>
                                            <div className="relative w-full h-9 bg-gray-100 dark:bg-slate-900 rounded-lg overflow-hidden border border-gray-200 dark:border-slate-700 group-hover:ring-2 group-hover:ring-blue-300 transition-all">
                                                <div className="absolute inset-y-0 left-0 flex" style={{ width: pct + '%' }}>
                                                    {countCompleted > 0 && <div className="h-full bg-green-500 transition-all" style={{ width: (countCompleted / (dProjects.length || 1)) * 100 + '%' }}></div>}
                                                    {countOngoing > 0 && <div className={`h-full ${deptColor} transition-all`} style={{ width: (countOngoing / (dProjects.length || 1)) * 100 + '%' }}></div>}
                                                    {countOverdue > 0 && <div className="h-full bg-red-500 transition-all" style={{ width: (countOverdue / (dProjects.length || 1)) * 100 + '%' }}></div>}
                                                </div>
                                                {dProjects.length > 0 && (
                                                    <div className="absolute inset-0 flex items-center px-3 text-xs font-bold text-white drop-shadow-[0_0_4px_rgba(0,0,0,0.5)]">
                                                        {countCompleted}/{countOngoing}/{countOverdue}
                                                    </div>
                                                )}
                                            </div>
                                        </button>
                                    );
                                })}
                            </div>

                            <div className="mt-5 pt-3 border-t border-gray-200 dark:border-slate-700 text-right text-xs text-gray-500 dark:text-slate-400">
                                Jumlah keseluruhan: <span className="font-bold text-gray-700 dark:text-slate-200">{projects.length} aktiviti</span>
                            </div>
                        </div>
                    )}
"""

# Actually the ringkasan section content is complex. Let me take a different approach.
# I'll remove the activeTab gate and move the entire block to after ProjectTimeline
# using string manipulation.

print("\nStep 1-5: Applying all edits...")

html = html.replace(old_ringkasan_at_top, "{/* RINGKASAN AKTIVITI - PLACEHOLDER REMOVED FROM TOP */}")

# ===== EDIT 6: Update ProjectTimeline to always show compact =====
old = "{(activeTab === 'sukuan' || activeTab === null) && <ProjectTimeline activeProjects={activeProjects} completedProjects={completedProjects} compact={activeTab !== 'sukuan'} />}"
new = "<ProjectTimeline activeProjects={activeProjects} completedProjects={completedProjects} compact={true} />"
html = html.replace(old, new)

# ===== EDIT 7: Insert Ringkasan AFTER ProjectTimeline =====
insert_marker = "compact={true} />"
insert_after = f"""compact={{true}} />
                        
                            {{{{ringkasan_section}}}}"""

# Actually, let me do this differently. I'll find where ProjectTimeline is and add ringkasan after it.
# Let me first add the ringkasan HTML right after the ProjectTimeline line
html = html.replace(
    "compact={true} />",
    f"""compact={{true}} />
                        
{ringkasan_html}"""
)

# ===== EDIT 8: Update body background with 70% black overlay =====
old_bg = """<div className={`relative min-h-screen bg-gray-50 dark:bg-slate-900 dark:bg-slate-950 text-gray-900 dark:text-slate-100 dark:text-slate-100 pb-16 font-sans fade-in bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] dark:bg-[url('https://www.transparenttextures.com/patterns/hexellence.png')] ${!isAuthenticated ? 'blur-[8px] opacity-40 pointer-events-none select-none h-screen overflow-hidden' : ''}`}>"""
# Add before: pseudo-element for overlay
new_bg = """<div className={`relative min-h-screen bg-gray-50 dark:bg-black text-gray-900 dark:text-slate-100 dark:text-slate-100 pb-16 font-sans fade-in bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] dark:bg-[url('https://www.transparenttextures.com/patterns/hexellence.png')] ${!isAuthenticated ? 'blur-[8px] opacity-40 pointer-events-none select-none h-screen overflow-hidden' : ''}`}>
                        <div className="absolute inset-0 bg-black/70 pointer-events-none z-0"></div>
                        <div className="relative z-10">"""
html = html.replace(old_bg, new_bg)

# Close the z-10 wrapper before the closing of the main div
# The main div closes after all sections. Let me find the correct closing.
# The main div closes like: </div> before the auth overlay or before </>
# Actually looking at code, after all sections, there's the admin modal, report modal, etc.
# Let me find the right place to close the z-10 wrapper

# Actually the main div (relative min-h-screen...) closes much later. Let me find where.
# I'll look for where the main div's closing tag </div> is after the content sections.
idx = html.find("/* PAPARAN AKSES DIHADKAN */")
if idx > 0:
    # Find the closing </div> of the main dashboard div -- it should be right before Access Denied
    print(f"  Found 'AKSES DIHADKAN' marker at {idx}")
    # The main div should close with </div> after all main content before the auth overlay
    # Let's look at the structure around this area
    pass

# Simpler approach: Let me close the z-10 div just before the closing of the main dashboard div
# I need to find the correct </div> that closes the min-h-screen div.
# Looking at the structure: the min-h-screen div contains: header + tab bar + main + nothing much after
# Since this is complex, let me just add a matching </div> at the end of the main content sections

# After all the section rendering (for matriks, sektor, lengkap), the main div closes
# The structure is: <main>...sections...</main></div> (closing main div)
# I need to find the </div> that closes the min-h-screen main div
# Let me look for the pattern after the completed section ends

# Find the end of main content - there's </main> then the main div's </div>
idx = html.find("</main>")
if idx > 0:
    before_main_close = html[:idx]
    after_main_close = html[idx:]
    # Add z-10 closing div before </main>
    html = before_main_close + """                        </div>
                    """ + after_main_close
    print(f"  Added z-10 close before </main> at {idx}")

# ===== EDIT 9: Remove the activeTab-gated sections (matriks/sektor/lengkap) 
# since they're now only in drawers =====
# These sections should be removed from inside the main div
# They will be added inside drawer components

# Actually, the sections for matriks, sektor, lengkap currently render INSIDE the main div
# gated by {activeTab === 'xxx' && (...)}. Since activeTab is replaced by openPanel,
# these sections will NEVER render (since there's no activeTab state anymore).
# I should either:
# A. Remove them entirely and put their content in drawers
# B. Keep them and reuse in drawers

# For now, keep them but they won't render (activeTab no longer exists, so gates are false)
# This means the sections are dead code. Let me remove them to keep the file clean.

# Actually, the gates use "activeTab === 'matriks'" etc. Since activeTab is now openPanel,
# and openPanel is never 'matriks' as a state variable with that name... wait, the gates
# reference "activeTab" which no longer exists. In JavaScript, undefined === 'matriks' is false,
# so they'd all be hidden. But the variable is undefined and would cause a reference error!

# Wait, no. activeTab is removed and replaced with openPanel. But the conditions like
# {activeTab === 'matriks' && ...} would cause a ReferenceError since activeTab is not defined.

# I need to handle this. Options:
# 1. Remove all the gated sections entirely (dead code)
# 2. Replace activeTab with openPanel in the conditions

# Actually, I should remove them from the main page and add them inside drawer components.

# Let me remove the sections and their closing braces
# matriks section: line 1318-1366
# sektor section: line 1368-1453
# lengkap section: line 1455-...

# These are removed from the main flow and will be added in drawer components at the end.

print("Step 6-9: Removed activeTab gates, updating drawer structure...")

# Remove matriks section (gated by activeTab === 'matriks')
# We'll keep the sections but change their gates to use openPanel
# Actually, the sections have local state (sort configs) that we need

# SIMPLEST APPROACH: just change activeTab references to openPanel in the remaining sections
# This way the sections only render when the panel is open
# BUT the sections are inside the main div with position relative, so they can't be fixed-position drawers

# BETTER APPROACH: Move the sections out of the main div, into the return at the end
# But that's complex string manipulation.

# BEST APPROACH: Keep the sections where they are, gate them with openPanel.
# Render the drawer (fixed overlay + close button) also gated by openPanel.
# The sections become "invisible" drawers that are overlaid by the fixed drawer shell.
# No wait, the sections are INSIDE the relative main div, so they can't be fixed overlays.

# OK let me just rip out the sections from inside main div and put them in drawer components
# at the end of the return statement, along with a fixed-position drawer shell.

# Remove the matriks section
matriks_start = html.find("{openPanel === 'matriks' && (")  # This won't exist, I haven't changed it
# Actually the condition is still {activeTab === 'matriks' && ...}
# Since activeTab is undefined, this expression evaluates to (undefined === 'matriks') which is false
# So the content never renders. But there's no ReferenceError because it's JSX - the variable
# "activeTab" would be a reference error.

# Hmm, in React/JSX, if I reference an undefined variable, it WILL throw a ReferenceError.
# So I need to either:
# 1. Remove the conditions and their content
# 2. Replace activeTab with a variable that exists

# Let me remove the sections entirely and put them in drawer components

# Find all {activeTab === 'xxx' && (...)} patterns and either:
# - Remove them (they're dead code)
# - Or change to {false && (...)} 

# Actually, since I already removed the activeTab variable declaration (changed to openPanel),
# the JSX will have a ReferenceError when it sees activeTab

# So I MUST remove/replace all references to activeTab

# Let me find and replace all remaining activeTab references
count = html.count("activeTab")
print(f"  Remaining 'activeTab' references: {count}")

if count > 0:
    # Find them and fix them
    # Replace {activeTab === 'xxx' && with {false && 
    import re
    html = re.sub(r"\{activeTab === '(matriks|sektor|lengkap)' && ", "{false && ", html)
    
    # Check if any remain
    count2 = html.count("activeTab")
    print(f"  After fix, remaining 'activeTab' references: {count2}")

# ===== EDIT 10: Add Drawer Components at the end =====
# Drawer data - need these variables in scope
drawer_code = """
                            {/* ========================================================= */}
                            {/* SIDE DRAWER: SUKUAN TAHUN (chart + table) */}
                            {/* ========================================================= */}
                            {openPanel === 'sukuan' && (
                                <div className="fixed inset-0 z-[200]">
                                    <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" onClick={() => setOpenPanel(null)}></div>
                                    <div className="absolute top-0 right-0 h-full w-full max-w-4xl bg-white dark:bg-slate-800 shadow-2xl overflow-y-auto animate-[slideIn_0.3s_ease-out] border-l border-gray-200 dark:border-slate-700">
                                        <div className="sticky top-0 bg-white dark:bg-slate-800 z-10 flex items-center justify-between px-6 py-4 border-b border-gray-200 dark:border-slate-700">
                                            <h2 className="text-xl font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2">
                                                <i data-lucide="calendar-days" className="w-5 h-5 text-blue-600"></i> Sukuan Tahun
                                            </h2>
                                            <button onClick={() => setOpenPanel(null)} className="text-gray-400 hover:text-gray-600 dark:hover:text-slate-200 p-2 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors">
                                                <i data-lucide="x" className="w-5 h-5"></i>
                                            </button>
                                        </div>
                                        <div className="p-6">
                                            <ProjectTimeline activeProjects={activeProjects} completedProjects={completedProjects} compact={false} />
                                        </div>
                                    </div>
                                </div>
                            )}

                            {/* ========================================================= */}
                            {/* SIDE DRAWER: MATRIKS KEPENTINGAN */}
                            {/* ========================================================= */}
                            {openPanel === 'matriks' && (
                                <div className="fixed inset-0 z-[200]">
                                    <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" onClick={() => setOpenPanel(null)}></div>
                                    <div className="absolute top-0 right-0 h-full w-full max-w-4xl bg-white dark:bg-slate-800 shadow-2xl overflow-y-auto animate-[slideIn_0.3s_ease-out] border-l border-gray-200 dark:border-slate-700">
                                        <div className="sticky top-0 bg-white dark:bg-slate-800 z-10 flex items-center justify-between px-6 py-4 border-b border-gray-200 dark:border-slate-700">
                                            <h2 className="text-xl font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2">
                                                <i data-lucide="layout-grid" className="w-5 h-5 text-blue-600"></i> Carta Matriks Kepentingan
                                            </h2>
                                            <button onClick={() => setOpenPanel(null)} className="text-gray-400 hover:text-gray-600 dark:hover:text-slate-200 p-2 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors">
                                                <i data-lucide="x" className="w-5 h-5"></i>
                                            </button>
                                        </div>
                                        <div className="p-6">
                                            <p className="text-sm text-gray-500 dark:text-slate-400 mb-4">
                                                Tarik (drag) dan lepaskan (drop) projek untuk menyusun tahap keutamaannya.
                                            </p>
                                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 bg-gray-50 dark:bg-slate-900 p-4 rounded-xl border border-gray-100 dark:border-slate-600">
                                                <QuadrantBox title="Penting & Segera (Buat Terus)" category="Penting & Segera" icon="flame" bgColor="bg-red-50" borderColor="border-red-200" titleColor="text-red-700" glow="shadow-[0_0_8px_rgba(239,68,68,0.3)]" />
                                                <QuadrantBox title="Penting, Tak Segera (Rancang)" category="Penting & Tak Segera" icon="calendar-clock" bgColor="bg-blue-50 dark:bg-blue-900/20" borderColor="border-blue-200" titleColor="text-blue-700" glow="shadow-[0_0_8px_rgba(59,130,246,0.3)]" />
                                                <QuadrantBox title="Kurang Penting, Segera (Serah)" category="Kurang Penting & Segera" icon="users-round" bgColor="bg-amber-50" borderColor="border-amber-200" titleColor="text-amber-700" glow="shadow-[0_0_8px_rgba(245,158,11,0.3)]" />
                                                <QuadrantBox title="Kurang Penting, Tak Segera (Simpan)" category="Kurang Penting & Tak Segera" icon="archive" bgColor="bg-gray-100 dark:bg-slate-800" borderColor="border-gray-300 dark:border-slate-600" titleColor="text-gray-600 dark:text-slate-300" glow="shadow-[0_0_8px_rgba(148,163,184,0.3)]" />
                                            </div>
                                            {openPanel === 'matriks' && activeProjects.filter(p => !p.Kepentingan || p.Kepentingan === 'Belum Ditetapkan').length > 0 && (
                                                <div 
                                                    className="mt-4 p-4 border-2 border-dashed border-gray-300 dark:border-slate-600 rounded-xl bg-white dark:bg-slate-800 transition-all" 
                                                    onDragOver={(e) => handleDragOver(e)} 
                                                    onDrop={(e) => handleDrop(e, 'Belum Ditetapkan')}
                                                >
                                                    <h3 className="text-sm font-bold text-gray-600 dark:text-slate-300 mb-3 flex items-center gap-2"><i data-lucide="help-circle" className="w-4 h-4"></i> Projek Belum Ditetapkan Kepentingan</h3>
                                                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                                                        {activeProjects.filter(p => !p.Kepentingan || p.Kepentingan === 'Belum Ditetapkan').map(p => (
                                                            <ProjectBar key={p.Projek} project={p} />
                                                        ))}
                                                    </div>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                </div>
                            )}

                            {/* ========================================================= */}
                            {/* SIDE DRAWER: MENGIKUT SEKTOR */}
                            {/* ========================================================= */}
                            {openPanel === 'sektor' && (
                                <div className="fixed inset-0 z-[200]">
                                    <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" onClick={() => setOpenPanel(null)}></div>
                                    <div className="absolute top-0 right-0 h-full w-full max-w-4xl bg-white dark:bg-slate-800 shadow-2xl overflow-y-auto animate-[slideIn_0.3s_ease-out] border-l border-gray-200 dark:border-slate-700">
                                        <div className="sticky top-0 bg-white dark:bg-slate-800 z-10 flex items-center justify-between px-6 py-4 border-b border-gray-200 dark:border-slate-700">
                                            <h2 className="text-xl font-bold text-gray-800 dark:text-slate-100 flex items-center gap-2">
                                                <i data-lucide="building-2" className="w-5 h-5 text-blue-600"></i> Projek Mengikut Sektor
                                            </h2>
                                            <div className="flex items-center gap-3">
                                                {panelSelectedDept && (
                                                    <span className="px-3 py-1 rounded-full bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 text-xs font-bold flex items-center gap-1.5">
                                                        <i data-lucide="filter" className="w-3 h-3"></i>
                                                        {panelSelectedDept}
                                                        <button onClick={() => setPanelSelectedDept(null)} className="ml-1 hover:text-red-500 transition-colors">&times;</button>
                                                    </span>
                                                )}
                                                <button onClick={() => setOpenPanel(null)} className="text-gray-400 hover:text-gray-600 dark:hover:text-slate-200 p-2 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors">
                                                    <i data-lucide="x" className="w-5 h-5"></i>
                                                </button>
                                            </div>
                                        </div>
                                        <div className="p-6">
                                            {/* Quick filter buttons */}
                                            <div className="flex gap-2 mb-6 flex-wrap">
                                                {['Semua','Pentadbiran','Akademik','Hal Ehwal Siswazah'].map(dept => (
                                                    <button key={dept} 
                                                        onClick={() => setPanelSelectedDept(dept === 'Semua' ? null : dept)}
                                                        className={`px-4 py-1.5 rounded-full text-xs font-bold transition-colors ${(dept === 'Semua' && !panelSelectedDept) || panelSelectedDept === dept ? 'bg-unisza-blue text-white' : 'bg-gray-100 dark:bg-slate-700 text-gray-600 dark:text-slate-300 hover:bg-gray-200 dark:hover:bg-slate-600'}`}>
                                                        {dept}
                                                    </button>
                                                ))}
                                            </div>
                                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                                {Object.entries(departmentConfig).filter(([deptName]) => !panelSelectedDept || deptName === panelSelectedDept).map(([deptName, config]) => {
                                                    let deptProjects = activeProjects.filter(p => p.Jabatan === deptName);
                                                    deptProjects.sort((a, b) => {
                                                        if (activeSortConfig === 'taktikal') {
                                                            const isOverdueA = checkIsOverdue(a.TarikhAsal, a.Kemajuan);
                                                            const isOverdueB = checkIsOverdue(b.TarikhAsal, b.Kemajuan);
                                                            if (isOverdueA && !isOverdueB) return -1;
                                                            if (!isOverdueA && isOverdueB) return 1;
                                                            if (isOverdueA && isOverdueB) {
                                                                const daySpentA = getDaySpentPercentageValue(a.TarikhMula, a.TarikhAsal);
                                                                const daySpentB = getDaySpentPercentageValue(b.TarikhMula, b.TarikhAsal);
                                                                return daySpentB - daySpentA;
                                                            }
                                                            return (parseInt(b.Kemajuan) || 0) - (parseInt(a.Kemajuan) || 0);
                                                        } else if (activeSortConfig === 'prog_desc') {
                                                            return (parseInt(b.Kemajuan) || 0) - (parseInt(a.Kemajuan) || 0);
                                                        } else if (activeSortConfig === 'prog_asc') {
                                                            return (parseInt(a.Kemajuan) || 0) - (parseInt(b.Kemajuan) || 0);
                                                        } else if (activeSortConfig === 'date_asc') {
                                                            const dateA = parseDateForSort(a.TarikhAsal);
                                                            const dateB = parseDateForSort(b.TarikhAsal);
                                                            if (dateA === 0 && dateB === 0) return 0;
                                                            if (dateA === 0) return 1;
                                                            if (dateB === 0) return -1;
                                                            return dateA - dateB;
                                                        }
                                                        return 0;
                                                    });
                                                    return (
                                                        <div key={deptName} className="flex flex-col bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-gray-200 dark:border-slate-700">
                                                            <div className={\`\${config.headerBg} px-5 py-3 rounded-t-xl text-white flex justify-between items-center\`}>
                                                                <div className="flex items-center gap-2">
                                                                    <i data-lucide={getDeptIcon(deptName)} className="w-5 h-5"></i>
                                                                    <h3 className="font-bold">{deptName}</h3>
                                                                </div>
                                                                <span className="text-xs bg-white/20 px-2 py-1 rounded-full">{deptProjects.length}</span>
                                                            </div>
                                                            <div className="p-4 flex-1 bg-gray-50/50">
                                                                {deptProjects.map((project, index) => <ProjectBar key={index} project={project} />)}
                                                                {deptProjects.length === 0 && !loading && <div className="text-center py-6 text-gray-400 dark:text-slate-500 text-sm border-2 border-dashed border-gray-200 dark:border-slate-700 rounded-lg">Tiada projek direkodkan.</div>}
                                                            </div>
                                                        </div>
                                                    );
                                                })}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            )}

                            {/* ========================================================= */}
                            {/* SIDE DRAWER: PROJEK LENGKAP */}
                            {/* ========================================================= */}
                            {openPanel === 'lengkap' && (
                                <div className="fixed inset-0 z-[200]">
                                    <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" onClick={() => setOpenPanel(null)}></div>
                                    <div className="absolute top-0 right-0 h-full w-full max-w-4xl bg-white dark:bg-slate-800 shadow-2xl overflow-y-auto animate-[slideIn_0.3s_ease-out] border-l border-gray-200 dark:border-slate-700">
                                        <div className="sticky top-0 bg-purple-500 px-6 py-4 text-white flex items-center justify-between">
                                            <h2 className="text-lg font-bold tracking-wide flex items-center gap-2"><i data-lucide="check-circle" className="w-5 h-5"></i> PROJEK LENGKAP</h2>
                                            <button onClick={() => setOpenPanel(null)} className="text-purple-100 hover:text-white p-2 hover:bg-purple-600 rounded-md transition-colors">
                                                <i data-lucide="x" className="w-5 h-5"></i>
                                            </button>
                                        </div>
                                        <div className="p-6 overflow-x-auto">
                                            <table className="w-full text-sm text-left text-gray-600 dark:text-slate-300">
                                                <thead className="text-xs text-gray-700 dark:text-slate-200 uppercase bg-gray-50 dark:bg-slate-900 border-b border-gray-200 dark:border-slate-700">
                                                    <tr>
                                                        <th className="px-6 py-4 font-semibold">Bil</th>
                                                        <th className="px-6 py-4 font-semibold cursor-pointer hover:bg-purple-100 transition-colors" onClick={() => requestSort('Projek')}>
                                                            <div className="flex items-center w-max">Projek {renderSortIcon('Projek')}</div>
                                                        </th>
                                                        <th className="px-6 py-4 font-semibold cursor-pointer hover:bg-purple-100 transition-colors" onClick={() => requestSort('TarikhMula')}>
                                                            <div className="flex items-center w-max">Tarikh Mula {renderSortIcon('TarikhMula')}</div>
                                                        </th>
                                                        <th className="px-6 py-4 font-semibold cursor-pointer hover:bg-purple-100 transition-colors" onClick={() => requestSort('TarikhSebenar')}>
                                                            <div className="flex items-center w-max">Tarikh Siap {renderSortIcon('TarikhSebenar')}</div>
                                                        </th>
                                                        <th className="px-6 py-4 font-semibold cursor-pointer hover:bg-purple-100 transition-colors" onClick={() => requestSort('Jabatan')}>
                                                            <div className="flex items-center w-max">Bahagian {renderSortIcon('Jabatan')}</div>
                                                        </th>
                                                        <th className="px-6 py-4 font-semibold text-center" data-html2canvas-ignore>Tindakan</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    {sortedCompletedProjects.map((project, index) => (
                                                        <tr key={index} className="bg-white dark:bg-slate-800 border-b hover:bg-purple-50/50 transition-colors">
                                                            <td className="px-6 py-3 font-medium text-gray-900 dark:text-slate-100">{index + 1}</td>
                                                            <td className="px-6 py-3 font-semibold text-gray-800 dark:text-slate-100">
                                                                <div className="flex items-center gap-1.5 w-max">
                                                                    <i data-lucide={getDeptIcon(project.Jabatan)} className={\`w-4 h-4 flex-shrink-0 \${project.Jabatan === 'Pentadbiran' ? 'text-blue-600' : project.Jabatan === 'Akademik' ? 'text-orange-600' : 'text-green-600'}\`} title={project.Jabatan}></i>
                                                                    <span>{project.Projek}</span>
                                                                    {project.Catatan && (
                                                                        <div className="relative group/tooltip flex items-center">
                                                                            <svg className="w-4 h-4 text-purple-500 opacity-80 flex-shrink-0 cursor-help" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                                                                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/><path d="M9 9h6"/><path d="M9 13h6"/>
                                                                            </svg>
                                                                            <div className="absolute left-full ml-2 top-1/2 -translate-y-1/2 w-64 md:w-72 bg-gray-700 text-white rounded-md p-3 opacity-0 invisible group-hover/tooltip:opacity-100 group-hover/tooltip:visible transition-all duration-200 z-[999] shadow-xl font-normal text-xs whitespace-normal break-words leading-relaxed pointer-events-none">
                                                                                {project.Catatan}
                                                                            </div>
                                                                        </div>
                                                                    )}
                                                                </div>
                                                            </td>
                                                            <td className="px-6 py-3">{project.TarikhMula || '-'}</td>
                                                            <td className="px-6 py-3 text-purple-700 font-medium">{project.TarikhSebenar || project.TarikhAkhir || '-'}</td>
                                                            <td className="px-6 py-3">{project.Jabatan}</td>
                                                            <td className="px-6 py-3 text-center" data-html2canvas-ignore>
                                                                <button onClick={() => handleEditClick(project)} className="text-blue-600 hover:text-blue-800 font-medium">Lihat Butiran</button>
                                                            </td>
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            )}
"""

# Insert drawer components just before the closing </div> of the main dashboard div
# Actually, we should insert them AFTER the main div closes, inside the React fragment
# Let me find a good insertion point

# The main dashboard div closes just before the "AKSES DIHADKAN" overlay
# But we've been doing insertions at the end of the file which gets messy

# Let me insert the drawers right before the closing of the React fragment (before </>
# which is at the end of the App component)

# Find the end of the main dashboard div - it's just before {!isAuthenticated && (AKSES DIHADKAN)}
idx = html.find("/* PAPARAN AKSES DIHADKAN */")
if idx > 0:
    # Find the last </div> before this - that closes the main dashboard div
    # Then add the drawer code after it
    end_main_div = html.rfind("</div>", 0, idx)
    if end_main_div > 0:
        before = html[:end_main_div]
        after = html[end_main_div:]
        # Close the z-10 div before the main div closes, then add drawer code
        # The structure should be:
        #   </main>
        #   </div> (z-10 close) 
        #   </div> (main dashboard div close)
        #   {drawers}
        # Actually I already added the z-10 close. Let me figure out where we are.
        
        # Actually the z-10 wrapper div starts at line ~1213 (right after main bg div)
        # and the z-10 I added closes before </main>
        # The main div then closes after </main>
        # So the structure is:
        # <div className="relative min-h-screen...">
        #   <div className="absolute inset-0 bg-black/70..."></div> (overlay)
        #   <div className="relative z-10"> (content wrapper)
        #     <header>...header...</header>
        #     <main>...content...</main>
        #     </div> (z-10 close - newly added)
        # </div> (main bg div close - existing)
        # 
        # Drawers go AFTER the main bg div closes (they have fixed positioning)
        
        # Insert drawers after the main bg div closing tag
        before_parts = html.split("</main>")
        if len(before_parts) == 2:
            # after </main>, find the first </div> (closes z-10) and second </div> (closes main bg div)
            rest = before_parts[1]
            # Add drawers after the main div closes
            # The main div closes after the z-10 which is right after </main>
            # So after </main>, we have: </div></div> (z-10 + main)
            # Insert after those
            
            # Find both closing divs
            # Actually let me just use a different approach - add drawers at the very end of return
            print(f"  Adding drawers to end of return...")

# Simpler approach: just append the drawer code after "{!isAuthenticated && (AKSES DIHADKAN)}"
# Wait, that's inside the main div.
# Let me just add drawers OUTSIDE the main div, after the main div closes.

# The main div closes just before "PAPARAN AKSES DIHADKAN"
# The closing is: </div> (main closes) then the access denied modal

# Let me find the last div before the auth overlay
idx_overlay = html.find("/* PAPARAN AKSES DIHADKAN */")
# Go backwards from there to find the main div closure
# The pattern is: </div></div> before the overlay comment
before_overlay = html[:idx_overlay]
# Find the last </div></div>
last_two_divs = before_overlay.rstrip().endswith("</div>\n</div>") or before_overlay.rstrip().endswith("</div></div>")

# Find where to put drawers: between main div closing and AKSES DIHADKAN
# Actually simpler: just put drawers at the very end, before </>

# Let me find the auth overlay section
auth_idx = html.find("{!isAuthenticated && (")
# The main div that contains auth overlay starts with:
# <div className="fixed inset-0 z-[1000] flex items-center justify-center">
# This is INSIDE the main app div but it's fixed-position
# Actually no - let me re-check. 

# The structure is:
# return (
#   <>
#     {/* RINGKASAN - removed to bottom */}
#     {/* TOAST */}
#     {/* MAIN DASHBOARD DIV - min-h-screen */}
#       <header>
#       <tab bar>
#       <main>
#         <ProjectTimeline compact />
#         <Ringkasan (moved to bottom) />
#       </main>
#     </div> <!-- main bg div close -->
#     
#     {/* AKSES DIHADKAN - outside main div */}
#     {!isAuthenticated && (...)}
#     
#     {/* MODALS - outside main div */}
#     {showAdminModal && (...)}
#     {showReportModal && (...)}
#     {showModal && (...)}
#     {showConfirmDelete && (...)}
#   </>
# )

# So drawers should go between the main div close and the modals/overlays

# Let me just add drawer code before the first modal/overlay
# Find "AKSES DIHADKAN" section
auth_marker = "/* PAPARAN AKSES DIHADKAN (BLURRED OVERLAY) */"
# The closing of the main div is right before this

# Let me find the end of the main div more precisely
# Look for: </div> (closes z-10) </div> (closes main bg div) then whitespace then auth marker
import re
# Find the pattern: </main> then some closing divs then the auth overlay
pattern = r"(</main>\s*</div>\s*</div>\s*)\s*/\*\s*PAPARAN AKSES DIHADKAN"
match = re.search(pattern, html)
if match:
    end_main = match.start(1)
    print(f"  Found main div close at {end_main}")
    # Insert z10 close (already added) + drawer code
else:
    # Try different pattern - the z10 close may have changed things
    pattern2 = r"</main>\s*</div>\s*/\*\s*PAPARAN AKSES DIHADKAN"
    match2 = re.search(pattern2, html)
    if match2:
        print(f"  Found main div close (z10 already added) at {match2.start()}")
    else:
        print("  WARNING: Could not find main div close pattern")

# Given the complexity, let me just insert drawer code at the very end right before </>
# Find the last occurrence of the Fragment closing
frag_close = html.rfind("</>")
if frag_close > 0:
    before_frag = html[:frag_close]
    after_frag = html[frag_close:]
    html = before_frag + "\n" + drawer_code + "\n" + after_frag
    print(f"  Drawers inserted before </> at {frag_close}")

with open(fp, 'w', encoding='utf-8') as f:
    f.write(html)

# Final verification
final_count = html.count("activeTab")
print(f"\nFinal 'activeTab' references remaining: {final_count}")
print(f"Final 'openPanel' references: {html.count('openPanel')}")
print(f"Final 'slideIn' CSS present: {'slideIn' in html}")
print(f"Final 'bg-black/70' overlay present: {'bg-black/70' in html}")
print(f"Done!")
PYEOF
