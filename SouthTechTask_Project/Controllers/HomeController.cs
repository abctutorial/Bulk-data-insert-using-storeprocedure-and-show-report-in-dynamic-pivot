using SouthTechTask.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SouthTechTask.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }


        public JsonResult SaveData(List<EmployeeBonusDetail> listOfDataToSave)
        {
            List<string> savedRecord = new List<string>();
            try
            {
                DataTable tvp = new DataTable();
                tvp.Columns.Add(new DataColumn("Emp_Id", typeof(string)));
                tvp.Columns.Add(new DataColumn("Emp_Name", typeof(string)));
                tvp.Columns.Add(new DataColumn("Emp_Bonus", typeof(string)));

                // populate DataTable from my List here
                foreach (var item in listOfDataToSave)
                    tvp.Rows.Add(new object[] { item.EmployeeId, item.EmployeeName, item.EmployeeBonusAmount });
                SqlConnection conn = new SqlConnection("Data Source=.;Initial Catalog=TechnicalTest;Integrated Security=True");

                SqlCommand cmd = new SqlCommand("dbo.SaveEmpBonusRecord", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                SqlParameter tvparam = cmd.Parameters.AddWithValue("@arrayList", tvp);
                tvparam.SqlDbType = SqlDbType.Structured;
                tvparam.Direction = ParameterDirection.Input;
                tvparam.TypeName = "dbo.tpEmpBonus_List";

                conn.Open();
                SqlDataReader myReader = cmd.ExecuteReader();
                while (myReader.Read())
                {
                    savedRecord.Add(myReader.GetString(0));
                }
                myReader.Close();
            }
            catch (Exception ex)
            {
                savedRecord.Add(ex.Message);
            }
            return Json(savedRecord, JsonRequestBehavior.AllowGet);
        }
    }
}